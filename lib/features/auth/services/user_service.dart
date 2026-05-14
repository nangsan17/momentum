import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String email,
    required String username,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
          'uid': uid,
          'email': email,
          'username': username,
          'imageUrl': '',
        });
  }

  Future<Map<String, dynamic>?>
  getUser(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    return doc.data();
  }

  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
          'username': username,
        });
  }

  Future<void> updateProfileImage({
    required String uid,
    required String imageUrl,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
          'imageUrl': imageUrl,
        });
  }
}