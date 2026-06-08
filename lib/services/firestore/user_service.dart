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
    String? contactNumber,
    String? address,
  }) async {
    await users.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.value,
      'contactNumber': contactNumber ?? '',
      'address': address ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      // Approval flags: customers are auto-approved (self-registered).
      // Staff/vets need admin approval; admins are always approved.
      'approved': role == UserRole.admin || role == UserRole.customer ? true : false,
    });
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await users.get();
    return snapshot.docs.map((doc) => {
      ...doc.data(),
      'docId': doc.id,
    }).toList();
  }

  Future<void> updateUser({
    required String uid,
    String? name,
    String? email,
    UserRole? role,
    bool? approved,
    String? contactNumber,
    String? address,
    String? imageUrl,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (role != null) updates['role'] = role.value;
    if (approved != null) updates['approved'] = approved;
    if (contactNumber != null) updates['contactNumber'] = contactNumber;
    if (address != null) updates['address'] = address;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await users.doc(uid).update(updates);
    }
  }

  Future<void> deleteUser(String uid) async {
    await users.doc(uid).delete();
  }

  Future<UserRole?> getUserRole(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data();
    if (data == null) return null;

    return UserRoleX.fromValue(data['role'] as String?);
  }

  Future<String?> getUserName(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data();
    if (data == null) return null;

    return data['name'] as String?;
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

