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

  Future<List<UserProgress>> getTopPlayers({int limit = 50}) async {
    final snapshot = await _usersCollection
        .orderBy('xp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserProgress.fromJson(data);
    }).toList();
  }

  Future<List<UserProgress>> getWeeklyLeaders({int limit = 50}) async {
    final weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final snapshot = await _usersCollection
        .where('last_active',
            isGreaterThanOrEqualTo: weekStart.toIso8601String())
        .orderBy('last_active', descending: true)
        .orderBy('xp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserProgress.fromJson(data);
    }).toList();
  }

  Future<List<Course>> loadCourses() async {
    final snap = await _db.collection('courses').get();
    if (snap.docs.isEmpty) return [];
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return Course.fromJson(data);
    }).toList();
  }

  Future<Map<String, dynamic>?> getCourseTranslation(
      String courseId, String lang) async {
    try {
      final doc = await _db
          .collection('courses')
          .doc(courseId)
          .collection('translations')
          .doc(lang)
          .get();
      if (doc.exists && doc.data() != null) {
        return Map<String, dynamic>.from(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  Future<List<Challenge>> loadAllChallenges() async {
    final snap = await _db.collection('challenges').get();
    final docs = snap.docs.toList();
    return docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return Challenge.fromJson(data);
    }).toList();
  }

  Future<List<Challenge>> loadApprovedUserChallenges() async {
    final snap = await _db
        .collection('user_challenges')
        .where('approved', isEqualTo: true)
        .get();
    final docs = snap.docs.toList();
    docs.sort((a, b) {
      int getMs(dynamic val) {
        if (val is Timestamp) return val.millisecondsSinceEpoch;
        if (val is String)
          return DateTime.tryParse(val)?.millisecondsSinceEpoch ?? 0;
        return 0;
      }

      return getMs(b.data()['created_at'])
          .compareTo(getMs(a.data()['created_at']));
    });
    return docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return Challenge.fromJson(data);
    }).toList();
  }

  Future<String?> getPistonUrl() async {
    try {
      final doc = await _db.collection('config').doc('piston').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return (data['piston_base_url']) as String?;
      }
    } catch (_) {}
    return null;
  }
}
