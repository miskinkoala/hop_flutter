import 'dart:io'; // Import for the File class
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'pages/edit_profile_page.dart';
import 'pages/my_trips_page.dart';
import 'pages/edit_favourite_locations_page.dart';
import 'pages/reviews_page.dart';
import 'pages/settings_privacy_page.dart';
import 'pages/notifications.dart';
import 'main.dart'; // Import for HomePage
import 'pages/paymentPage.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String name = 'Loading..';
  String email = 'Loading..';
  String avgPoint = "0.0";
  String userBalance = "0.0"; // New balance field
  String car_model = 'Add your car model';
  String about = 'Tell something about yourself to show others';
  File? profilePicture; // Store profile picture
  File? updatedProfilePicture; // Temp store for updated profile picture

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    const String getUserDataurl =
        'http://209.38.227.170:3000/users/app-container/profile-page';

    try {
      SharedPreferences prefs2 = await SharedPreferences.getInstance();
      String? authToken = prefs2.getString('auth');
      String? userId = prefs2.getString('id');

      final response = await http.post(
        Uri.parse(getUserDataurl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'_id': userId}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          name = '${userData['firstName']} ${userData['secondName']}';
          email = '${userData['email']}';
          car_model = '${userData['carModel']}';
          about = '${userData['about']}';
          avgPoint =
              '${(userData['userAveragePoint'] as num?)?.toString() ?? "0.0"}';
          userBalance =
              '${(userData['userBalance'] as num?)?.toStringAsFixed(2) ?? "0.0"}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user data')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.green,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Color.fromARGB(255, 13, 95, 31)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
            toolbarHeight: 30,
            title: Text(
              "Profile",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color.fromARGB(255, 13, 95, 31),
                ),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: updatedProfilePicture != null
                        ? FileImage(updatedProfilePicture!)
                        : profilePicture != null
                            ? FileImage(profilePicture!)
                            : const AssetImage('images/logo.jpeg')
                                as ImageProvider,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car_model,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            avgPoint,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            "$userBalance \₺",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final updatedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                name: name,
                                email: email,
                                car_model: car_model,
                                about: about,
                                profilePicture:
                                    updatedProfilePicture ?? profilePicture,
                              ),
                            ),
                          );

                          if (updatedData != null) {
                            setState(() {
                              name = updatedData['name'];
                              email = updatedData['email'];
                              car_model = updatedData['carModel'];
                              about = updatedData['about'];
                              updatedProfilePicture =
                                  updatedData['profilePicture'];
                            });
                          }
                        },
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // About Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                about,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            // Menu Options
            _buildMenuItem(
              context,
              title: 'My Trips',
              icon: Icons.drive_eta,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyTripsPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              title: 'Reviews',
              icon: Icons.rate_review,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewsPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              title: 'Edit Favourite Locations',
              icon: Icons.edit_location,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditFavoriteLocationsPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              title: 'Payment',
              icon: Icons.payment,
              onTap: () async {
                // Navigate to the PaymentPage and await the result
                final newBalance = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentPage(),
                  ),
                );

                // If there's a new balance returned, update the user balance in your UI
                if (newBalance != null) {
                  setState(() {
                    // Assuming you have a variable for the user balance
                    userBalance = newBalance;
                  });
                }
              },
            ),
            _buildMenuItem(
              context,
              title: 'Settings & Privacy',
              icon: Icons.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPrivacyPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 144.0,
                horizontal: 16.0,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 114, 110, 110),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required String title,
      required IconData icon,
      required Function() onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: Icon(icon, color: Colors.green[600]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
