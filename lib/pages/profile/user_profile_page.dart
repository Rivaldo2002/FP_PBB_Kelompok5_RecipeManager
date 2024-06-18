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
  bool _isProfileExisting = false;
  bool? _isAdmin;

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
      UserProfile? userProfile = await _firestoreService.getUserProfile(user.uid);
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
          _isProfileExisting = true;
          _isAdmin = userProfile.isAdmin;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
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
        isAdmin: _isAdmin ?? false,
      );

      if (_isProfileExisting) {
        await _firestoreService.updateUserProfile(userProfile);
      } else {
        await _firestoreService.createUserProfile(userProfile);
      }

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

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold), // Added bold style
      alignLabelWithHint: true,
    );
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (user != null) ProfilePicture(userId: user.uid),
              SizedBox(height: 10),
              Text(
                _isAdmin! ? 'A D M I N' : 'U S E R',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _fullNameController,
                decoration: _inputDecoration('Full Name'),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _dateOfBirthController,
                decoration: _inputDecoration(
                  'Date of Birth (YYYY-MM-DD)',
                ).copyWith(icon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'Male',
                            groupValue: _selectedGender,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Female'),
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
                  ],
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _weightController,
                decoration: _inputDecoration('Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _heightController,
                decoration: _inputDecoration('Height (m)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _bmiController,
                decoration: _inputDecoration('BMI'),
                readOnly: true,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submitProfile,
                child: Text('S U B M I T'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
