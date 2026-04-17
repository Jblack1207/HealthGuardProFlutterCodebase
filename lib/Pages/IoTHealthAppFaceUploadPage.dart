import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Helpers/FaceApiService.dart';

class IoTHealthAppFaceUploadPage extends StatefulWidget {
  final String deviceId;

  const IoTHealthAppFaceUploadPage({
    super.key,
    required this.deviceId,
  });

  @override
  State<IoTHealthAppFaceUploadPage> createState() =>
      _IoTHealthAppFaceUploadPageState();
}

class _IoTHealthAppFaceUploadPageState
    extends State<IoTHealthAppFaceUploadPage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _photos = [];
  bool _isUploading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_photos.length >= 5) return;

    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );

    if (photo == null) return;

    setState(() {
      _photos.add(photo);
      _error = null;
      _success = null;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _upload() async {
    final personName = _nameController.text.trim();

    if (personName.isEmpty) {
      setState(() {
        _error = 'Please enter a name';
      });
      return;
    }

    if (_photos.length != 5) {
      setState(() {
        _error = 'Please take exactly 5 photos';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
      _success = null;
    });

    try {
      await FaceUploadApiService().uploadFaceImages(
        deviceId: widget.deviceId,
        personName: personName,
        files: _photos,
      );

      if (!mounted) return;

      setState(() {
        _success = 'Face images uploaded successfully';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Upload failed: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });
    }
  }

  bool get _isUploadEnabled {
    final photo = _photos.length;

    return photo == 5;
  }

  Widget _buildPhotoTile(int index) {
    final hasPhoto = index < _photos.length;

    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xff27272A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: hasPhoto
          ? Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_photos[index].path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () => _removePhoto(index),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      )
          : const Center(
        child: Text(
          'Empty',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xff1F1F1F),
        title: const Text('Add Face Photos'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: [
          Text(
            'Device ID: ${widget.deviceId}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter person name',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xff27272A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Take 5 photos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(5, _buildPhotoTile),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                //enabled colouring
                backgroundColor: const Color(0xffffc21c).withOpacity(0.95),
                foregroundColor: Colors.black,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: Colors.white24,
                    // width: isEnabled ? 3 : 0,
                  ),
                ),
              ),
              onPressed: _photos.length >= 5 ? null : _takePhoto,
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              label: Text('Take Photo (${_photos.length}/5)' , style: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploadEnabled
                  ? (_isUploading ? null : _upload)
                  : null,
              style: ElevatedButton.styleFrom(
                //enabled colouring
                backgroundColor: const Color(0xffffc21c).withOpacity(0.95),
                foregroundColor: Colors.black,
                //disabled colouring
                disabledBackgroundColor: const Color(0xffffc21c).withOpacity(0.2),
                disabledForegroundColor: Colors.black54,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: Colors.white24,
                    width: _isUploadEnabled ? 3 : 0,
                  ),
                ),
              ),
              child: Text(_isUploading ? 'Uploading...' : 'Upload Face Set', style: TextStyle(color: Colors.black)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          if (_success != null) ...[
            const SizedBox(height: 12),
            Text(
              _success!,
              style: const TextStyle(color: Colors.greenAccent),
            ),
          ],
        ],
      ),
    );
  }
}
