import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_recipemanager/components/profile_picture.dart';
import 'package:fp_recipemanager/models/user_profile.dart';
import 'package:fp_recipemanager/services/user_profile_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileService _firestoreService = UserProfileService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();

  String? _selectedGender;
  int? _calculatedAge;
  String? _profilePicturePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _weightController.addListener(_calculateBMI);
    _heightController.addListener(_calculateBMI);
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      UserProfile? userProfile =
      await _firestoreService.getUserProfile(user.uid);
      if (userProfile != null) {
        setState(() {
          _fullNameController.text = userProfile.fullName ?? '';
          _dateOfBirthController.text = userProfile.dateOfBirth != null
              ? DateFormat('yyyy-MM-dd').format(userProfile.dateOfBirth!)
              : '';
          _selectedGender = userProfile.gender;
          _weightController.text =
          userProfile.weight != null ? userProfile.weight.toString() : '';
          _heightController.text =
          userProfile.height != null ? userProfile.height.toString() : '';
          _bmiController.text =
          userProfile.bmi != null ? userProfile.bmi.toString() : '';
          _calculatedAge = userProfile.age;
          _profilePicturePath = 'profilePicture/${userProfile.userId}';
        });

        // Introduce a delay before hiding the loading spinner
        await Future.delayed(Duration(milliseconds: 200));

        setState(() {
          _isLoading = false; // Data has been loaded
        });
      }
    }
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    if (weight != null && height != null && height > 0) {
      final bmi = weight / (height * height);
      setState(() {
        _bmiController.text = bmi.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _bmiController.text = '';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
        _calculatedAge = AgeCalculator.age(pickedDate).years;
      });
    }
  }

  void _submitProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      UserProfile userProfile = UserProfile(
        userId: user.uid,
        fullName: _fullNameController.text.isNotEmpty
            ? _fullNameController.text
            : null,
        email: user.email!,
        dateOfBirth: _dateOfBirthController.text.isNotEmpty
            ? DateTime.parse(_dateOfBirthController.text)
            : null,
        gender: _selectedGender,
        weight: _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : null,
        height: _heightController.text.isNotEmpty
            ? double.parse(_heightController.text)
            : null,
        bmi: _bmiController.text.isNotEmpty
            ? double.parse(_bmiController.text)
            : null,
        profilePicturePath: 'profilePicture/${user.uid}',
      );

      await _firestoreService.createUserProfile(userProfile);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Profile Saved'),
            content: Text('Your profile has been successfully saved.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_calculateBMI);
    _heightController.removeListener(_calculateBMI);
    _weightController.dispose();
    _heightController.dispose();
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(
        child: SpinKitFadingCircle(
          color: Colors.white,
          size: 50.0,
        ),
      )
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (user != null)
                ProfilePicture(userId: user.uid), // Pass userId to ProfilePicture widget
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _dateOfBirthController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      icon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 20),
                  if (_calculatedAge != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40.0, 0, 0, 0),
                      child: Text('Age: $_calculatedAge years',
                          style: TextStyle(fontSize: 16)),
                    ),
                  SizedBox(height: 20),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender', style: TextStyle(fontSize: 16)),
                  ListTile(
                    title: const Text('Male'),
                    leading: Radio<String>(
                      value: 'Male',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Female'),
                    leading: Radio<String>(
                      value: 'Female',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (m)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _bmiController,
                decoration: InputDecoration(labelText: 'BMI'),
                readOnly: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProfile,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
