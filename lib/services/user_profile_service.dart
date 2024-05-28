import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_recipemanager/models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserProfile userProfile) async {
    await _db.collection('userProfiles').doc(userProfile.userId).set(userProfile.toMap());
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _db.collection('userProfiles').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _db.collection('userProfiles').doc(userProfile.userId).update(userProfile.toMap());
  }
}
