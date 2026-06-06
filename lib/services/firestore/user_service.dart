import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_role.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    await users.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.value,
      'createdAt': FieldValue.serverTimestamp(),
      // Approval flags (admins can approve staff/vets after manual creation).
      'approved': role == UserRole.admin ? true : false,
    });
  }

  Future<UserRole?> getUserRole(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data();
    if (data == null) return null;

    return UserRoleX.fromValue(data['role'] as String?);
  }

  Future<bool> isUserApproved(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data();
    if (data == null) return false;

    // Admin is always approved by definition.
    final role = UserRoleX.fromValue(data['role'] as String?);
    if (role == UserRole.admin) return true;

    return (data['approved'] as bool?) ?? false;
  }
}

