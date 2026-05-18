import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';

class VerificationCameraPage extends StatefulWidget {
  final VoidCallback? onVerificationComplete;

  const VerificationCameraPage({
    this.onVerificationComplete,
    super.key
  });

  @override
  State<VerificationCameraPage> createState() => _VerificationCameraPageState();
}

class _VerificationCameraPageState extends State<VerificationCameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedPhoto;
  bool _isFrontCamera = true;
  bool _isLoading = false;
  int _step = 0; // 0: instructions, 1: camera, 2: review

  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras!.isNotEmpty) {
        final frontCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras!.first,
        );
        _cameraController = CameraController(
          frontCamera, 
          ResolutionPreset.high,
        );
        _initializeControllerFuture = _cameraController.initialize();
        setState(() {});
      }

    } catch (e) {
      print('Camera initalization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission denied: $e')),
      );
    }
  }

  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    try {
      _isFrontCamera = !_isFrontCamera;
      final selectedCamera = _isFrontCamera
        ? cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras!.first,
          )
        : cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => cameras!.first,
          );
      
      await _cameraController.dispose();
      _cameraController = CameraController(selectedCamera, ResolutionPreset.high);
      _initializeControllerFuture = _cameraController.initialize();
      setState(() {
        
      });
    } catch (e) {
      print('Camera switch error: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedPhoto = image;
        _step = 2; // move to review screen
      });
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  Future<void> _uploadPhoto() async {
    if (_capturedPhoto == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final storage = FirebaseStorage.instance;
      final photoFile = File(_capturedPhoto!.path);
      final ref = storage.ref('users/$userId/verification_selfie.jpg');

      await ref.putFile(photoFile);
      final downloadUrl = await ref.getDownloadURL();

      // update the user with verification selfie url
      final updatedUser = auth.user!.copyWith(
        isVerified: true,
        verificationSelfieUrl: downloadUrl,
      );
      auth.user = updatedUser;
      auth.notifyListeners();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification selfie uploaded successfully!')),
      );

      // navigate to next step in the auth flow (dietary tags)
      widget.onVerificationComplete?.call();
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _step == 0
        ? _buildInstructionsScreen()
        : _step == 1
          ? _buildCameraScreen()
          : _buildReviewScreen(),
    );
  }

  Widget _buildInstructionsScreen() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Photo Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We need to verify that you are a real person, so take a selfie for us!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 60),
                // face icon illustration
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: const Icon(
                    Icons.face,
                    size: 100,
                    color: Colors.white30,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _step = 1;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA5800),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ), 
                child: const Text(
                  'Take a Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildCameraScreen() {
    return FutureBuilder(
      future: _initializeControllerFuture, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _step = 0;
                        }), 
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_cameraController),
                      // circular face guide overlay
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                      // corner markers
                      Positioned(
                        top: 50,
                        left: 50,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2),
                              left: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 50,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2),
                              right: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 50,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 2),
                              left: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        right: 50,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 2),
                              right: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Take a clear photo where\n your face can be clearly\n seen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // flip camera button
                          if (cameras != null && cameras!.length > 1)
                            FloatingActionButton(
                              onPressed: _switchCamera,
                              mini: true,
                              backgroundColor: const Color(0xFFFA5800),
                              child: const Icon(Icons.flip_camera_ios),
                            ),
                          // capture button
                          FloatingActionButton(
                            onPressed: _takePicture,
                            backgroundColor: const Color(0xFFFA5800),
                            child: const Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFA5800)),
          );
        }
      }
    );
  }

  Widget _buildReviewScreen() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _step = 1;
                  }), 
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ready to finalize your photo?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // preview image in a circle container
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                    image: DecorationImage(
                      image: FileImage(File(_capturedPhoto!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA5800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                      : const Text(
                        'Finalize',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => setState(() {
                      _step = 1;
                    }),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFA5800), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ), 
                    child: const Text(
                      'Retake Picture',
                      style: TextStyle(
                        color: Color(0xFFFA5800),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}