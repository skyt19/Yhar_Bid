/// lib/models/user_model.dart
/// โมเดลผู้ใช้งาน — เก็บข้อมูลบทบาท, สไตล์ AI, และข้อมูล Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';

/// บทบาทผู้ใช้งาน 3 ประเภทตาม SRS
enum UserRole { student, corporateEmployee, educator }

/// สไตล์การสื่อสารของ AI (User Persona)
enum AiPersonality { politeJarvis, friendly, aggressiveMotivator }

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final UserRole role;
  final AiPersonality personality;
  final DateTime createdAt;
  final String languageCode; // 'th' หรือ 'en'

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.personality,
    required this.createdAt,
    this.languageCode = 'th',
  });

  /// แปลง enum UserRole เป็น String เพื่อเก็บใน Firestore
  String get roleString => role.name;

  /// แปลง enum AiPersonality เป็น String
  String get personalityString => personality.name;

  /// แปลงจาก Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data()!;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (UserRole r) => r.name == (data['role'] as String? ?? 'student'),
        orElse: () => UserRole.student,
      ),
      personality: AiPersonality.values.firstWhere(
        (AiPersonality p) => p.name == (data['personality'] as String? ?? 'politeJarvis'),
        orElse: () => AiPersonality.politeJarvis,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      languageCode: data['languageCode'] as String? ?? 'th',
    );
  }

  /// แปลงเป็น Map เพื่อบันทึกลง Firestore
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'role': roleString,
      'personality': personalityString,
      'createdAt': Timestamp.fromDate(createdAt),
      'languageCode': languageCode,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    UserRole? role,
    AiPersonality? personality,
    DateTime? createdAt,
    String? languageCode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      personality: personality ?? this.personality,
      createdAt: createdAt ?? this.createdAt,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
