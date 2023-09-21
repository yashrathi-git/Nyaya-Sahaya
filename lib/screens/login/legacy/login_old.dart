// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law/screens/stakeholders/client/client_screen.dart';
import 'package:law/screens/stakeholders/lawyer/lawyer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum UserRole {
  lawyer,
  client,
}

String userRoleToString(UserRole role) {
  return role.toString().split('.').last;
}

UserRole stringToUserRole(String role) {
  return UserRole.values.firstWhere(
    (e) => e.toString().split('.').last == role,
    orElse: () => UserRole.client,
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoginForm = true;
  bool _isLoading = false;
  UserRole _userRole = UserRole.client;

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final String? uid = _prefs.getString('uid');
      final String? email = _prefs.getString('email');
      final String? identifier = _prefs.getString('identifier');
      final String? storedUserRole = _prefs.getString('userRole');

      if (uid != null &&
          email != null &&
          identifier != null &&
          storedUserRole != null) {
        setState(() {
          _userRole = stringToUserRole(storedUserRole);
        });

        if (_userRole == UserRole.client) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ClientScreen(),
            ),
          );
        } else if (_userRole == UserRole.lawyer) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LawyerScreen(),
            ),
          );
        }
      }
    }
  }

  void _saveUserDataToPrefs(String uid, String email, String identifier) {
    _prefs.setString('uid', uid);
    _prefs.setString('email', email);
    _prefs.setString('identifier', identifier);
    _prefs.setString('userRole', userRoleToString(_userRole));
  }

  Future<void> _signInWithEmail(
      String email, String password, String identifier) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User user = userCredential.user!;
      final String uid = user.uid;

      final DocumentSnapshot userData =
          await _firestore.collection('users').doc(uid).get();

      if (userData.exists) {
        final String storedUserRole = userData['userRole'];
        final UserRole userRole = stringToUserRole(storedUserRole);

        if (userRole == _userRole && userData['identifier'] == identifier) {
          await _storeUserData(uid, email, identifier);

          _saveUserDataToPrefs(uid, email, identifier);

          _prefs.setBool('isLoggedIn', true);

          if (_userRole == UserRole.client) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ClientScreen()));
          } else if (_userRole == UserRole.lawyer) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LawyerScreen()));
          }
        } else {
          // Handle the case where userRole or identifier doesn't match
          // Set _isLoading to false and possibly show an error message
          setState(() {
            _isLoading = false;
          });
          // Show an error message, e.g., using a Scaffold or AlertDialog
          // You can use a Flutter dialog or SnackBar to display the message.
        }
      } else {
        // Handle the case where userData doesn't exist
        // Set _isLoading to false and possibly show an error message
        setState(() {
          _isLoading = false;
        });
        // Show an error message, e.g., using a Scaffold or AlertDialog
        // You can use a Flutter dialog or SnackBar to display the message.
      }
    } on FirebaseAuthException {
      // Handle Firebase authentication errors
      setState(() {
        _isLoading = false;
      });
      // Show an error message, e.g., using a Scaffold or AlertDialog
      // You can use a Flutter dialog or SnackBar to display the message.
    }
  }

  Future<void> _createAccount(
      String email, String password, String identifier) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User user = userCredential.user!;
      final String uid = user.uid;

      await _storeUserData(uid, email, identifier);

      _saveUserDataToPrefs(uid, email, identifier);

      _prefs.setBool('isLoggedIn', true);

      if (_userRole == UserRole.client) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ClientScreen()));
      } else if (_userRole == UserRole.lawyer) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LawyerScreen()));
      }
    } on FirebaseAuthException {
      setState(() {
        _isLoading = false;
      });

    }
  }

  Future<void> _storeUserData(
      String uid, String email, String identifier) async {
    await _firestore.collection('users').doc(uid).set({
      'name': email.split('@')[0],
      'email': email,
      'identifier': identifier,
      'userRole': userRoleToString(_userRole),
      if (_userRole == UserRole.client) 'caseNumber': identifier,
      if (_userRole == UserRole.lawyer) 'barNumber': identifier,
      'uid': uid,
    });
  }

  void _submitForm() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String identifier = _identifierController.text.trim();

    if (_isLoginForm) {
      _signInWithEmail(email, password, identifier);
    } else {
      _createAccount(email, password, identifier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        title: Text(
          _isLoginForm ? 'Login' : 'Create Account',
          style: const TextStyle(
            color: Colors.white, // App bar text color
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              DropdownButtonFormField<UserRole>(
                value: _userRole,
                onChanged: (UserRole? newValue) {
                  setState(() {
                    _userRole = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: UserRole.client,
                    child: Text('Client',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  DropdownMenuItem(
                    value: UserRole.lawyer,
                    child: Text('Lawyer',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: 'Select Role',
                  border: OutlineInputBorder(
                    // Input field border
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
              if (_userRole == UserRole.lawyer || _userRole == UserRole.client)
                const SizedBox(height: 20), // Add spacing
              TextFormField(
                controller: _identifierController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _userRole == UserRole.lawyer
                      ? 'Bar Number'
                      : 'Case Number',
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isLoginForm ? 'Login' : 'Create Account',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _toggleFormMode,
                child: Text(
                  _isLoginForm
                      ? 'Create an account'
                      : 'Have an account? Sign in',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (_isLoading) const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFormMode() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }
}
