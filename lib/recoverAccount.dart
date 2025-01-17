import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Recoveraccount extends StatelessWidget {
  final _emailController = TextEditingController();

  Recoveraccount({super.key});
  void _recoverAccount(BuildContext context) async {
    print("deneme");
    String email = _emailController.text;
    print(email);
    if (email.isEmpty) {
      // Show error if email is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }
    Map<String, String> body = {'email': email};
    const String url = 'http://209.38.227.170:3000/users/recover-account';

    try {
      print("response");
      print("Sending request to url:${url}");
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body), // Proper JSON formatting
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print("200");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset link sent!")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send email. Try again later.")),
      );
      print("Error: $error");
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
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              "Recover Account",
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
        padding: const EdgeInsets.only(top: 120),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter your Email to reset your password",
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
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: 'Email Adress...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => _recoverAccount(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0D3BF),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send Email',
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
