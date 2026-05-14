import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String email,
    required String username,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'imageBase64': '',
    });
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {'username': username},
      SetOptions(merge: true),
    );
  }

  Future<void> uploadProfileImage({
    required String uid,
    required Uint8List imageBytes,
  }) async {
    final base64Image = base64Encode(imageBytes);
    await _firestore.collection('users').doc(uid).set(
      {'imageBase64': base64Image},
      SetOptions(merge: true),
    );
  }

  Future<void> updateProfileImage({
    required String uid,
    required String imageUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {'imageUrl': imageUrl},
      SetOptions(merge: true),
    );
  }
}