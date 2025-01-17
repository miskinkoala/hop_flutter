import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:path/path.dart' as p; // Use an alias to avoid conflicts
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String car_model;
  final String about;
  final File? profilePicture;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.car_model,
    required this.about,
    this.profilePicture,
  });

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _carModelController;
  late TextEditingController _aboutController;
  File? _profilePicture;

  @override
  void initState() {
    super.initState();
    _carModelController = TextEditingController(text: widget.car_model);
    _aboutController = TextEditingController(text: widget.about);
    _profilePicture =
        widget.profilePicture; // Initialize with the passed profile picture
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

/*
  Future<void> _updateUserProfile() async {
    try {
      const String url =
          'http://209.38.227.170:3000/users/profile-page/edit-profile';

      final Map<String, dynamic> body = {
        'carModel': _carModelController.text,
        'about': _aboutController.text
      };
    } catch (e) {}
  }
*/


Future<void> _updateUserProfile() async {
    try {
      const String url =
          'http://209.38.227.170:3000/users/profile-page/edit-profile';

      SharedPreferences prefs3 = await SharedPreferences.getInstance();
      String? userId = prefs3.getString('id');
      

      // Prepare the body data
      final Map<String, dynamic> body = {
        '_id': userId, // Include the user ID
        'carModel': _carModelController.text,
        'about': _aboutController.text,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body), // Convert the body to JSON
      );

      // Check the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        // Handle errors
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update profile: ${errorData['message']}')),
        );
      }
    } catch (error) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }


Future<void> _updatePhoto() async {
  try {
    const String url = 'http://209.38.227.170:3000/users/profile-page/upload-profile-picture';

    // Prepare the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    String filePath = _profilePicture!.path.replaceAll('\\', "/");
    String? mimeType = lookupMimeType(filePath);
    print("_profilePicture: $_profilePicture");
    print("filepath: $filePath");
    print("MIME type: $mimeType");

    // Add file to the request
     var imageFile = await http.MultipartFile.fromPath(
      'profilePicture',
      filePath,
      contentType: mimeType != null
          ? MediaType.parse(mimeType)
          : MediaType('image', 'png'),
    );
    request.files.add(imageFile);

    // Send the request
    var response = await request.send();
    print("Response status: ${response.statusCode}");
    print("Response body: ${await response.stream.bytesToString()}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile picture')),
      );
    }
  } catch (error) {
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}
/*
Future<void> _updatePhoto() async {
  try {
    if (_profilePicture == null) {
      throw Exception('Profile picture is null');
    }

    var stream = http.ByteStream(_profilePicture!.openRead().cast<List<int>>());
    var length = await _profilePicture!.length();

    SharedPreferences prefs3 = await SharedPreferences.getInstance();
    String? userId = prefs3.getString('id');


    const String url = 'http://209.38.227.170:3000/users/profile-page/upload-profile-picture';
    print("_profilePicture");
    print(_profilePicture);

    // Prepare the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    var multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: p.basename(_profilePicture!.path),
    );
    print("multipartFile");
    print(multipartFile);


    request.files.add(multipartFile);
    request.fields['_id'] = userId!; // Assuming userId is never null

    // MIME type
    String? mimeType = lookupMimeType(_profilePicture!.path);
    var imageFile = await http.MultipartFile.fromPath(
      'profilePicture',
      _profilePicture!.path,
      contentType: mimeType != null
          ? MediaType.parse(mimeType)
          : MediaType('application', 'octet-stream'),
    );

    request.files.add(imageFile);

    // Send the request
    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture uploaded successfully!')),
      );
    } else {
      response.stream.bytesToString().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile picture: $value')),
        );
      });
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profilePicture != null
                          ? FileImage(_profilePicture!)
                          : const AssetImage('images/logo.jpeg')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Car Model',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _carModelController,
                decoration:
                    const InputDecoration(hintText: 'Enter your car model'),
              ),
              const SizedBox(height: 16),
              const Text(
                'About',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _aboutController,
                decoration: const InputDecoration(
                    hintText: 'Enter a short description about yourself'),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // First, update the user's profile data (car model, about, etc.)
                  await _updateUserProfile();

                  // Check if a new profile picture was selected and upload it
                  if (_profilePicture != null) {
                    await _updatePhoto();
                  }

                  // Return the updated data back to the previous screen
                  Navigator.pop(context, {
                    'name': widget.name,
                    'email': widget.email,
                    'carModel': _carModelController.text,
                    'about': _aboutController.text,
                    'profilePicture': _profilePicture,
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green[600],
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
