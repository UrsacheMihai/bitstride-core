// Interact with Firestore for user and configuration data.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_progress.dart';
import '../../models/exercise/exercise.dart';

// Handle data operations and service integration for the Firestore Service.
class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _db.collection('users');

  Future<UserProgress> loadUserProgress(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return UserProgress(uid: uid);
    }
    final data = doc.data() as Map<String, dynamic>;
    data['uid'] = uid;
    return UserProgress.fromJson(data);
  }

  Future<void> saveUserProgress(String uid, UserProgress progress) async {
    await _usersCollection.doc(uid).set(
          progress.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<Map<String, dynamic>> loadSettings(String uid) async {
    final doc = await _usersCollection
        .doc(uid)
        .collection('meta')
        .doc('settings')
        .get();
    if (!doc.exists || doc.data() == null) {
      return {
        'dark_mode': false,
        'language': 'en',
        'disable_motion': false,
      };
    }
    return Map<String, dynamic>.from(doc.data()!);
  }

  Future<void> saveSettings(String uid, Map<String, dynamic> settings) async {
    await _usersCollection
        .doc(uid)
        .collection('meta')
        .doc('settings')
        .set(settings);
  }

}