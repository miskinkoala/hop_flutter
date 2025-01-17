import 'package:flutter/material.dart';
import 'package:flutter_application_1/createTrip.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ChangePassword.dart';
import 'verify_page.dart';
import 'recoverAccount.dart';
import 'app_container.dart';
import 'favourite_locations_page.dart';
import 'chat_page.dart';
import 'search_trip.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/edit_favourite_locations_page.dart';
import 'package:flutter/services.dart';

class Appcolors {
  static const Color customGreen = Color(0xFFB4C17C);
  static const Color greenButton = Color(0xFF6B7B26);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/favorites': (context) => const FavoriteLocationsPage(),
        '/change-password': (context) => ChangePassword(),
        '/create-trip': (context) => const CreateTrip(),
        '/recover-account': (context) => Recoveraccount(),
        '/get-user-data': (context) => Recoveraccount(),
        '/app-container': (context) => const AppContainer(),
        '/app-container/favorite-page': (context) =>
            const FavoriteLocationsPage(),
        '/app-container/search-trips-page': (context) => const SearchTripPage(),
        '/app-container/create-trip-page': (context) => const CreateTrip(),
        '/app-container/chat-page': (context) => const ChatPage(),
        '/app-container/profile-page': (context) => const ProfilePage(),
        '/profil-page/edit-favorite-locations': (context) =>
            const EditFavoriteLocationsPage(),
        '/verify': (context) => VerificationCodePage(arguments: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind the AppBar
      appBar: AppBar(
        title: ClipRRect(
          child: Image.asset(
            "images/car.jpeg",
            fit: BoxFit.cover,
          ),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black),
        backgroundColor: Appcolors.customGreen
            .withOpacity(0.0), // Transparent AppBar for effect
        toolbarHeight: 200, // AppBar height
        elevation: 0, // Remove shadow if needed
      ),
      body: Stack(
        children: [
          Container(
            color: Appcolors.customGreen, // Background color for the main body
          ),
          // Container overflowing into AppBar
          Positioned(
            top: 250,
            bottom: 0, // Make it overflow upwards by adjusting this value
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ), // Rounded corners
              ),
              padding:
                  const EdgeInsets.all(20), // Add some padding if necessary
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(120),
                      child: Image.asset(
                        "images/logo.jpeg",
                        height: 120,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "Ready to Travel?",
                    style: GoogleFonts.inriaSans(
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize:
                            const Size(250, 50), // Fixed width and height
                        padding: EdgeInsets
                            .zero, // Remove padding to maintain exact size
                        backgroundColor: const Color(0xFFA9C533),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold)),
                    child: Text(
                      'Login',
                      style: GoogleFonts.inriaSans(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize:
                            const Size(250, 50), // Fixed width and height
                        padding: EdgeInsets
                            .zero, // Remove padding to maintain exact size
                        backgroundColor: const Color(0xFFD0D3BF),
                        foregroundColor: const Color(0xFF6B7B26),
                        textStyle: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold)),
                    child: Text('Sign Up', style: GoogleFonts.inriaSans()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscurePassword = true; // Initial state for password visibility

  void _login(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }
    const String url = 'http://209.38.227.170:3000/users/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: '{"email":"$email","password":"$password"}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("response data:$responseData");
        final String id = responseData['_id'];
        final String token =
            responseData['tokens']?['access_token']; // Backend'den dönen token

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', id);
        await prefs.setString('auth', token);

        Navigator.pushReplacementNamed(context, '/app-container');
      } else {
        // Bir hata oluştu
        print('Hata:aaa ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
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
        toolbarHeight: 120,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Text(
            "Welcome!",
            style: GoogleFonts.inriaSans(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sign in to your account",
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontFamily: 'InriaSans',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword, // Toggle visibility here
                decoration: InputDecoration(
                  labelText: 'Password...',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/recover-account');
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0D3BF),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF6B7B26),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/signup',
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _signUp(BuildContext context) async {
    // Fetch user data
    String firstName = _firstNameController.text.trim();
    String secondName = _secondNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

   

    // Field validation
    if (firstName.isEmpty ||
        secondName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }
    // Validate names (allow Turkish characters and spaces)
    if (!RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜ ]+$').hasMatch(firstName) || 
        !RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜ ]+$').hasMatch(secondName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Names can only contain alphabetic characters and spaces!')),
      );
      return;
    }
    // Validate email format
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address!')),
      );
      return;
    }

    // Password length validation
    if (password.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 5 characters long!')),
      );
      return;
    }
    // Password match check
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    // API URL'si
    const String url = 'http://209.38.227.170:3000/users/send-validation-code';

    // Map<String, String> body = {
    //   'firstName': firstName,
    //   'secondName': secondName,
    //   'email': email,
    //   'password': password,
    // };

    setState(() {
      _isLoading = true;
    });

    try {

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );
    

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        print("token:");
        print(token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Validation code sent to your email')),
        );
        Navigator.pushNamed(
          context,
          '/verify',
          arguments: {
            'email': email,
            'token': token,
            'firstName': firstName,
            'secondName': secondName,
            'password': password,
          },
        );
      } else {
        final error = jsonDecode(response.body)['msg'] ?? 'Unknown error';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Text("Let's Start",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              )),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Create new account",
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  )),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _firstNameController,
              inputFormatters: [
              FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ ]'), // Includes Turkish characters and spaces
              ),
              ],
              decoration: InputDecoration(
                labelText: 'First Name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _secondNameController,
              inputFormatters: [
              FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ ]'), // Includes Turkish characters and spaces
              ),
              ],
              decoration: InputDecoration(
                labelText: 'Last Name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _signUp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0D3BF),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Create Account',
                      style: GoogleFonts.inriaSans(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B7B26),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Do you have an account?",
                  style: GoogleFonts.inriaSans(),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    "Sign in",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
