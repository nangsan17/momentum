import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveUser({
    required String name,
    required String email,
  }) async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      getUserStream() {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots();
  }
}