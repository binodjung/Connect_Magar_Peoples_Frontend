import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/colors.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentFullName;
  final String email;
   final String currentMobile;
  final String? currentProfilePicture;

  const UpdateProfileScreen({
    Key? key,
    required this.currentUsername,
    required this.currentFullName,
    required this.email,
    required this.currentMobile,
    this.currentProfilePicture,
  }) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _mobileController;
  bool _isLoading = false;
  File? _image;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _fullNameController = TextEditingController(text: widget.currentFullName);
    _mobileController = TextEditingController(text: widget.currentMobile);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // Use MultipartRequest for image upload
      var request = http.MultipartRequest('PATCH', Uri.parse(ApiConstants.profile));
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['username'] = _usernameController.text;
      request.fields['full_name'] = _fullNameController.text;
      request.fields['mobile_number'] = _mobileController.text;

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        await prefs.setString('username', data['username']);
        await prefs.setString('full_name', data['full_name']);
        await prefs.setString('mobile_number', data['mobile_number']);
        if (data['profile_picture'] != null) {
          await prefs.setString('profile_picture', data['profile_picture']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        // If the server returns HTML (e.g. <!DOCTYPE html>), jsonDecode will fail
        String errorMessage = 'Failed to update profile (${response.statusCode})';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['error'] ?? error['message'] ?? errorMessage;
        } catch (e) {
          // If response is not JSON, we just use the status code message
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorText = 'Error: $e';
      if (e is FormatException) {
        errorText = 'Server Error: The server returned an invalid response. Please check your backend connections.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Update your personal details below.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Image Picker Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.lightGrey,
                      backgroundImage: _image != null 
                        ? FileImage(_image!) 
                        : (widget.currentProfilePicture != null 
                            ? NetworkImage(widget.currentProfilePicture!) as ImageProvider
                            : null),
                      child: (_image == null && widget.currentProfilePicture == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildLabel('Email (Not updateable)'),
              TextField(
                controller: TextEditingController(text: widget.email),
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildLabel('Username'),
              _buildTextField(_usernameController, 'Enter username'),
              const SizedBox(height: 20),
              
              _buildLabel('Full Name'),
              _buildTextField(_fullNameController, 'Enter full name'),
              const SizedBox(height: 20),
              
              _buildLabel('Mobile Number'),
              _buildTextField(_mobileController, 'Enter mobile number', keyboardType: TextInputType.phone),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
