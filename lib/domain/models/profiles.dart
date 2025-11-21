/// Simple user profile model stored under users/{uid}
class Profile {
  final String uid;
  final String fullName;
  final String matric;
  final String department;
  final String program;
  final String phone;
  final String email;

  Profile({
    required this.uid,
    required this.fullName,
    required this.matric,
    required this.department,
    required this.program,
    required this.phone,
    required this.email,
  });

  Profile copyWith({
    String? uid,
    String? fullName,
    String? matric,
    String? department,
    String? program,
    String? phone,
    String? email,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      matric: matric ?? this.matric,
      department: department ?? this.department,
      program: program ?? this.program,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'matric': matric,
      'department': department,
      'program': program,
      'phone': phone,
      'email': email,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      matric: map['matric'] as String,
      department: map['department'] as String,
      program: map['program'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }

  @override
  String toString() {
    return 'Profile(uid: $uid, name: $fullName, matric: $matric)';
  }
}