import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePassword extends StatelessWidget {
  final _passwordController = TextEditingController();
  final _confirmPassword = TextEditingController();

  ChangePassword({super.key});
  void _fetchUserDataAndChangePassword(BuildContext context) async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPassword.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter password")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords are not the same')),
      );
      return;
    }

    const String getUserDataUrl = 'http://209.38.227.170:3000/get-user-data';
    const String changePasswordUrl ='http://209.38.227.170:3000/change-password';

    try {
      // Step 1: Fetch user data
      final userResponse = await http.get(Uri.parse(getUserDataUrl));
      if (userResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user data')),
        );
        return;
      }

      // Parse user data
      final userData = jsonDecode(userResponse.body);
      String? accessToken = userData['tokens']?['acces_token'];

      if (accessToken == null || accessToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token is missing')),
        );
        return;
      }

      // Step 2: Make change password request
      final response = await http.post(
        Uri.parse(changePasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: '{"password":"$password"}',
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/recover-account');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Problem: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is a problem')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 140,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "Change Password",
              style: GoogleFonts.inriaSans(
                  textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              )),
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create Your new Password",
                    style: GoogleFonts.inriaSans(
                        textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'InriaSans',
                    )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Enter your email...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Password...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Confirm Password...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => _fetchUserDataAndChangePassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0D3BF),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF6B7B26),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
