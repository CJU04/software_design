class User {
  int? userid;
  String username;
  String password;
  String fullname;
  String usertype; // admin, staff, veterinarian, customer
  String contactNumber;
  String email;
  String address;
  String status;
  String? profileImagePath;

  User({
    this.userid,
    required this.username,
    required this.password,
    required this.fullname,
    required this.usertype,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.status,
    this.profileImagePath,
  });

  // Convert User object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'username': username,
      'password': password,
      'fullname': fullname,
      'usertype': usertype,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'status': status,
      'profileImagePath': profileImagePath,
    };
  }

  // Create User object from Map (database row)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userid: map['userid'],
      username: map['username'],
      password: map['password'],
      fullname: map['fullname'],
      usertype: map['usertype'],
      contactNumber: map['contactNumber'],
      email: map['email'],
      address: map['address'],
      status: map['status'],
      profileImagePath: map['profileImagePath'],
    );
  }

  User copyWith({
    int? userid,
    String? username,
    String? password,
    String? fullname,
    String? usertype,
    String? contactNumber,
    String? email,
    String? address,
    String? status,
    String? profileImagePath,
  }) {
    return User(
      userid: userid ?? this.userid,
      username: username ?? this.username,
      password: password ?? this.password,
      fullname: fullname ?? this.fullname,
      usertype: usertype ?? this.usertype,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      status: status ?? this.status,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

