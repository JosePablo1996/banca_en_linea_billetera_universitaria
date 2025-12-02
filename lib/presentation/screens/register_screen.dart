import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../../services/storage_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _universityController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Estados de fortaleza de contraseña
  String _passwordStrength = 'Débil';
  double _passwordStrengthValue = 0.0;
  Color _passwordStrengthColor = Colors.red;

  // Avatar
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingAvatar = false;
  String? _avatarUploadError;

  // Servicio de almacenamiento
  final StorageService _storageService = StorageService();

  // Estados de validación en tiempo real
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Colores del tema Banking Premium
  final Color _primaryColor = const Color(0xFF1A237E); // Azul bancario oscuro
  final Color _accentColor = const Color(0xFF00C853); // Verde financiero
  final Color _backgroundColor = const Color(0xFF0D1B2A); // Azul noche profundo
  final Color _cardColor = const Color(0xFF1B263B); // Azul carta
  final Color _goldColor = const Color(0xFFFFD700); // Dorado premium
  final Color _textColor = Colors.white;
  final Color _hintColor = Colors.white70;
  final Color _successColor = const Color(0xFF00C853);
  final Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();

    // Listeners para validación en tiempo real
    _fullNameController.addListener(() {
      setState(() {
        _isNameValid = _fullNameController.text.trim().length >= 2;
      });
    });

    _emailController.addListener(() {
      setState(() {
        final email = _emailController.text.trim();
        _isEmailValid = email.isNotEmpty && 
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      });
    });

    _phoneController.addListener(() {
      setState(() {
        final phone = _phoneController.text.trim();
        _isPhoneValid = phone.isEmpty || 
            RegExp(r'^[0-9]{10,15}$').hasMatch(phone.replaceAll(RegExp(r'[^0-9]'), ''));
      });
    });

    _passwordController.addListener(() {
      _updatePasswordStrength();
      setState(() {
        _isPasswordValid = _passwordController.text.length >= 6;
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _isConfirmPasswordValid = _confirmPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text == _passwordController.text;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _universityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String strengthText = 'Débil';
    Color strengthColor = Colors.red;

    if (password.isNotEmpty) {
      // Criterios de fortaleza
      if (password.length >= 6) strength += 0.3;
      if (password.length >= 8) strength += 0.2;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
      if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
      if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

      // Determinar texto y color
      if (strength < 0.4) {
        strengthText = 'Débil';
        strengthColor = Colors.red;
      } else if (strength < 0.7) {
        strengthText = 'Media';
        strengthColor = Colors.orange;
      } else {
        strengthText = 'Fuerte';
        strengthColor = _accentColor;
      }
    }

    setState(() {
      _passwordStrengthValue = strength;
      _passwordStrength = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
          _avatarUploadError = null; // Limpiar error anterior
        });
      }
    } catch (e) {
      setState(() {
        _avatarUploadError = 'Error al seleccionar imagen: $e';
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar Foto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Cámara',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galería',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: _hintColor,
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _goldColor.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 32, color: _textColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: _textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Por favor corrige los errores en el formulario');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (password != _confirmPasswordController.text) {
      _showErrorDialog('Las contraseñas no coinciden');
      return;
    }

    // Realizar el registro primero (sin avatar)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signUp(
      email, 
      password, 
      fullName, 
      studentId: _studentIdController.text.trim(),
      university: _universityController.text.trim(),
    );

    if (success) {
      // Si el registro fue exitoso, ahora subir el avatar (si existe)
      if (_avatarImage != null) {
        await _uploadAvatarAfterRegister();
      }
      
      // Guardar teléfono si existe
      if (phone.isNotEmpty) {
        await _updateUserPhone(phone);
      }
      
      await authProvider.resetBiometricForNewUser();
      _showSuccessDialog();
    } else {
      final error = authProvider.error;
      if (error?.contains('ya está registrado') == true || 
          error?.contains('User already registered') == true ||
          error?.contains('already registered') == true) {
        _showUserExistsDialog(email);
      } else {
        _showErrorDialog(error ?? 'Error al crear la cuenta');
      }
    }
  }

  Future<void> _uploadAvatarAfterRegister() async {
    setState(() {
      _isUploadingAvatar = true;
      _avatarUploadError = null;
    });
    
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No se pudo obtener el usuario después del registro');
      }
      
      // Verificar si el bucket de avatares existe
      final bucketExists = await _storageService.checkAvatarsBucket();
      if (!bucketExists) {
        throw Exception('El sistema de almacenamiento no está disponible');
      }
      
      // Subir imagen usando el ID del usuario real
      final avatarUrl = await _storageService.uploadProfileImage(
        _avatarImage!, 
        currentUser.id
      );
      
      if (avatarUrl == null) {
        throw Exception('No se pudo obtener la URL de la imagen subida');
      }
      
      // Actualizar el perfil del usuario con la URL del avatar
      await supabase
          .from('profiles')
          .update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser.id);
      
      print('✅ Avatar subido y asignado al perfil exitosamente: $avatarUrl');
      
    } catch (e) {
      print('❌ Error subiendo avatar después del registro: $e');
      setState(() {
        _avatarUploadError = 'Error al subir avatar: ${e.toString().replaceAll('Exception: ', '')}';
      });
      
      // Mostrar advertencia pero no detener el flujo
      _showAvatarWarning();
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _updateUserPhone(String phone) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser != null) {
        await supabase
            .from('profiles')
            .update({
              'phone': phone,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', currentUser.id);
        
        print('✅ Teléfono guardado en el perfil: $phone');
      }
    } catch (e) {
      print('⚠️ Error guardando teléfono: $e');
    }
  }

  void _showAvatarWarning() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _avatarUploadError ?? 'No se pudo subir la foto de perfil',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Entendido',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 20,
        shadowColor: _primaryColor.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_accentColor, _accentColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Cuenta Creada!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu cuenta ha sido creada exitosamente. Bienvenido a Mi Billetera Universitaria.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: _backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: _accentColor.withOpacity(0.5),
                  ),
                  child: Text(
                    'Continuar al Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error de Registro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: _textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserExistsDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: _goldColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Cuenta Existente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'El correo $email ya está registrado en Mi Billetera Universitaria.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¿Te gustaría iniciar sesión en su lugar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textColor,
                          side: BorderSide(color: _hintColor.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToLoginWithEmail(email);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: _backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Iniciar Sesión'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLoginWithEmail(String email) {
    Navigator.pushReplacementNamed(
      context, 
      '/login',
      arguments: {'email': email},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildStudentInfoSection(),
                      const SizedBox(height: 24),
                      _buildRegisterButton(authProvider),
                      const SizedBox(height: 16),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_primaryColor, _accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agregar Estudiante',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textColor,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Text(
                    'Crea tu cuenta universitaria',
                    style: TextStyle(
                      fontSize: 13,
                      color: _hintColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: _goldColor.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar y Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Avatar con estado de carga
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primaryColor.withOpacity(0.1),
                        border: Border.all(
                          color: _goldColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _avatarImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                _avatarImage!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 40,
                              color: _hintColor,
                            ),
                    ),
                    
                    // Botón de cámara
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: _backgroundColor, width: 2),
                          ),
                          child: _isUploadingAvatar
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                    
                    // Overlay de carga
                    if (_isUploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Estado de la foto
                if (_avatarUploadError != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _avatarUploadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (_avatarImage != null)
                  Text(
                    'Foto seleccionada ✅',
                    style: TextStyle(
                      color: _successColor,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Selecciona una foto (opcional)',
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 12,
                    ),
                  ),
                
                if (_isUploadingAvatar)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Subiendo foto después del registro...',
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información del perfil
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _backgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _goldColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información del Perfil',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProfileInfoRow('Foto de perfil', _avatarImage != null ? 'Sí' : 'No'),
                _buildProfileInfoRow('Longitud del nombre', '${_fullNameController.text.length} caracteres'),
                _buildProfileInfoRow('Email verificado', 'No'),
                _buildProfileInfoRow('Teléfono', _phoneController.text.isNotEmpty ? 'Sí' : 'No'),
                _buildProfileInfoRow('Almacenamiento', 'Supabase ✅'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Estudiante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStudentField(
            controller: _fullNameController,
            label: 'Nombre completo *',
            icon: Icons.person_outline_rounded,
            isValid: _isNameValid,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu nombre completo';
              }
              if (value.length < 2) {
                return 'Mínimo 2 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildStudentField(
            controller: _emailController,
            label: 'Correo Electrónico *',
            icon: Icons.email_rounded,
            isValid: _isEmailValid,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildStudentField(
            controller: _phoneController,
            label: 'Teléfono (opcional)',
            icon: Icons.phone_rounded,
            isValid: _isPhoneValid,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final phone = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (phone.length < 10 || phone.length > 15) {
                  return 'Teléfono inválido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildStudentField(
            controller: _studentIdController,
            label: 'ID de Estudiante (opcional)',
            icon: Icons.badge_rounded,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 3) {
                return 'Mínimo 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildStudentField(
            controller: _universityController,
            label: 'Universidad (opcional)',
            icon: Icons.school_rounded,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 3) {
                return 'Mínimo 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordField(
                controller: _passwordController,
                label: 'Contraseña *',
                obscureText: _obscurePassword,
                onToggle: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nivel de seguridad:',
                          style: TextStyle(
                            color: _hintColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _passwordStrength,
                          style: TextStyle(
                            color: _passwordStrengthColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width * _passwordStrengthValue * 0.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _passwordStrengthColor,
                              _passwordStrengthColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: _passwordStrengthColor.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmar Contraseña *',
            obscureText: _obscureConfirmPassword,
            onToggle: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'No coinciden';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool isValid = true,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: _textColor,
        fontSize: 14,
      ),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _hintColor,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _goldColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _goldColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        prefixIcon: Icon(icon, size: 18, color: _hintColor),
        filled: true,
        fillColor: _backgroundColor.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: controller.text.isNotEmpty && (label.contains('Email') || label.contains('Teléfono') || label.contains('Nombre'))
            ? Icon(
                isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 18,
                color: isValid ? _successColor : _errorColor,
              )
            : null,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: _textColor,
        fontSize: 14,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _hintColor,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _goldColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _goldColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        prefixIcon: Icon(Icons.lock_rounded, size: 18, color: _hintColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: _hintColor,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: _backgroundColor.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _hintColor,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(AuthProvider authProvider) {
    final isButtonDisabled = authProvider.isLoading || _isUploadingAvatar;
    
    return Column(
      children: [
        // Mostrar errores de avatar si existen
        if (_avatarUploadError != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nota: ${_avatarUploadError!}. La cuenta se creará sin foto.',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isButtonDisabled ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 8,
              shadowColor: _primaryColor.withOpacity(0.5),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isUploadingAvatar ? 'Completando registro...' : 'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta? ',
          style: TextStyle(
            color: _hintColor,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Iniciar Sesión',
            style: TextStyle(
              color: _goldColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}