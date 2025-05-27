class UserProfile {
  final String uid;
  final String cpf;
  final DateTime? birthDate;

  UserProfile({required this.uid, required this.cpf, this.birthDate});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      cpf: map['cpf'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'cpf': cpf,
        'birthDate': birthDate?.toIso8601String(),
      };
}
