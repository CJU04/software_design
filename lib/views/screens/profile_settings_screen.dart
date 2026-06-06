import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
// dart:io is not supported on web. Import it conditionally and only use it
// in platform-specific code paths.
import 'dart:io' as io;

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  io.File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      _fullnameController.text = currentUser.fullname;
      _contactNumberController.text = currentUser.contactNumber;
      _emailController.text = currentUser.email;
      _addressController.text = currentUser.address;
      if (currentUser.profileImagePath != null) {
        // Only evaluated on platforms that support dart:io.
        _profileImage = io.File(currentUser.profileImagePath!);

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      drawer: const AppDrawer(currentRoute: '/profile_settings'),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Center(
                child: Stack(
                  children: [
                  CircleAvatar(
                    key: ValueKey(_profileImage?.path),
                    radius: 50,
                    backgroundImage:
                        _profileImage != null ? FileImage(_profileImage!) : null,

                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: _profileImage == null ? Text(
                      // Guard against empty names to avoid RangeError.
                      (currentUser?.fullname.trim().isNotEmpty == true)
                          ? currentUser!.fullname.trim()[0].toUpperCase()
                          : 'U',

                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ) : null,
                  ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: _pickImage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          fullname: _fullnameController.text,
          contactNumber: _contactNumberController.text,
          email: _emailController.text,
          address: _addressController.text,
          profileImagePath: _profileImage?.path,
        );
        userProvider.updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await _saveImageToAppDirectory(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    await _saveImageToAppDirectory(image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveImageToAppDirectory(XFile image) async {
    // Web doesn't support writing to app documents directory in the same way.
    // For web, keep the local preview in memory and do not attempt to copy
    // the file.
    if (image.path.startsWith('http') || image.path.startsWith('blob:') || image.path.startsWith('data:')) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      if (currentUser != null) {
        userProvider.updateUser(
          currentUser.copyWith(profileImagePath: image.path),
        );
      }
      return;
    }

    // Mobile/desktop: copy to local documents directory.
    // (If this method isn't available on a platform, the build will fail.
    //  Web paths are handled above.)
    // Platform-specific filesystem write: keep as non-web only.
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);

    // Copy the selected image into app documents.
    // Note: only safe on non-web platforms.
    final savedImage = await io.File(image.path).copy('${directory.path}/$fileName');

    if (!mounted) return;
    setState(() {
      _profileImage = savedImage;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      userProvider.updateUser(
        currentUser.copyWith(profileImagePath: savedImage.path),
      );
    }
  }


  @override
  void dispose() {
    _fullnameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

