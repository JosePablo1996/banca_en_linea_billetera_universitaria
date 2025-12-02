class ProfileModel {
  final String id;
  final String email;
  final String? fullName;
  final String? studentId;
  final String? university;
  final String? avatarUrl;
  final String currency;
  final String language;
  final double monthlyBudget;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.studentId,
    this.university,
    this.avatarUrl,
    this.currency = 'USD',
    this.language = 'es',
    this.monthlyBudget = 0,
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      studentId: json['student_id'],
      university: json['university'],
      avatarUrl: json['avatar_url'],
      currency: json['currency'] ?? 'USD',
      language: json['language'] ?? 'es',
      monthlyBudget: (json['monthly_budget'] ?? 0).toDouble(),
      biometricEnabled: json['biometric_enabled'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'student_id': studentId,
      'university': university,
      'avatar_url': avatarUrl,
      'currency': currency,
      'language': language,
      'monthly_budget': monthlyBudget,
      'biometric_enabled': biometricEnabled,
      'notifications_enabled': notificationsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Método copyWith mejorado para edición de perfil
  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? studentId,
    String? university,
    String? avatarUrl,
    String? currency,
    String? language,
    double? monthlyBudget,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Siempre actualizar updatedAt
    );
  }

  // Métodos útiles para la UI
  String get displayName => fullName ?? 'Usuario';
  
  String get displayUniversity => university ?? 'No especificada';
  
  String get displayStudentId => studentId ?? 'No especificado';
  
  String get formattedBudget => '\$${monthlyBudget.toStringAsFixed(2)}';
  
  bool get hasAcademicInfo => (studentId != null && studentId!.isNotEmpty) || 
                              (university != null && university!.isNotEmpty);
  
  bool get hasCompleteProfile => fullName != null && fullName!.isNotEmpty;

  // Método para crear un perfil por defecto
  factory ProfileModel.defaultProfile(String userId, String userEmail) {
    final now = DateTime.now();
    return ProfileModel(
      id: userId,
      email: userEmail,
      fullName: null,
      studentId: null,
      university: null,
      avatarUrl: null,
      currency: 'USD',
      language: 'es',
      monthlyBudget: 0,
      biometricEnabled: false,
      notificationsEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Método para validar datos del perfil
  Map<String, String> validate() {
    final errors = <String, String>{};
    
    if (fullName != null && fullName!.isEmpty) {
      errors['fullName'] = 'El nombre no puede estar vacío';
    }
    
    if (fullName != null && fullName!.length < 2) {
      errors['fullName'] = 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (currency.isEmpty) {
      errors['currency'] = 'La moneda es requerida';
    }
    
    if (language.isEmpty) {
      errors['language'] = 'El idioma es requerido';
    }
    
    if (monthlyBudget < 0) {
      errors['monthlyBudget'] = 'El presupuesto no puede ser negativo';
    }
    
    return errors;
  }

  // Método para verificar si el perfil ha cambiado
  bool hasChanges(ProfileModel other) {
    return fullName != other.fullName ||
        studentId != other.studentId ||
        university != other.university ||
        currency != other.currency ||
        language != other.language ||
        monthlyBudget != other.monthlyBudget;
  }

  @override
  String toString() {
    return 'ProfileModel{id: $id, email: $email, fullName: $fullName, studentId: $studentId, university: $university, currency: $currency, language: $language, monthlyBudget: $monthlyBudget}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ProfileModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.studentId == studentId &&
        other.university == university &&
        other.avatarUrl == avatarUrl &&
        other.currency == currency &&
        other.language == language &&
        other.monthlyBudget == monthlyBudget &&
        other.biometricEnabled == biometricEnabled &&
        other.notificationsEnabled == notificationsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      studentId,
      university,
      avatarUrl,
      currency,
      language,
      monthlyBudget,
      biometricEnabled,
      notificationsEnabled,
    );
  }
}