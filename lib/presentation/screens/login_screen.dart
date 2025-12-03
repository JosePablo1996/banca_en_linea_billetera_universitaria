import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin { // Cambiado a TickerProviderStateMixin
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isCheckingBiometrics = false;
  Map<String, dynamic> _biometricStatus = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Animación mejorada para la barra de fortaleza
  late AnimationController _strengthAnimationController;
  late Animation<double> _strengthWidthAnimation;
  late Animation<Color?> _strengthColorAnimation;

  // Estados de fortaleza de contraseña
  String _passwordStrength = 'Débil';
  double _passwordStrengthValue = 0.0;
  Color _passwordStrengthColor = Colors.red;

  // Colores del tema Banking Premium (iguales al register)
  final Color _primaryColor = const Color(0xFF1A237E); // Azul bancario oscuro
  final Color _accentColor = const Color(0xFF00C853); // Verde financiero
  final Color _backgroundColor = const Color(0xFF0D1B2A); // Azul noche profundo
  final Color _cardColor = const Color(0xFF1B263B); // Azul carta
  final Color _goldColor = const Color(0xFFFFD700); // Dorado premium
  final Color _textColor = Colors.white;
  final Color _hintColor = Colors.white70;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones principales
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Configurar animación para la barra de fortaleza
    _strengthAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _strengthWidthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _strengthAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _strengthColorAnimation = ColorTween(
      begin: Colors.red,
      end: _accentColor,
    ).animate(
      CurvedAnimation(
        parent: _strengthAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    _checkBiometricStatus();

    // Listener para cambios en la contraseña
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _strengthAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String strengthText = 'Débil';
    Color strengthColor = Colors.red;

    if (password.isNotEmpty) {
      // Criterios de fortaleza con valores más precisos
      if (password.length >= 6) strength += 0.3;
      if (password.length >= 8) strength += 0.2;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
      if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
      if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

      // Asegurar que el valor esté entre 0 y 1
      strength = strength.clamp(0.0, 1.0);

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

    // Iniciar animación para la nueva fuerza
    _strengthAnimationController.value = 0;
    _strengthAnimationController.forward();

    setState(() {
      _passwordStrengthValue = strength;
      _passwordStrength = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _checkBiometricStatus() async {
    setState(() {
      _isCheckingBiometrics = true;
    });

    try {
      final status = await context.read<AuthProvider>().getFullBiometricStatus();
      
      if (kDebugMode) {
        print('📊 Estado biométrico completo desde LoginScreen: $status');
      }
      
      setState(() {
        _biometricStatus = status;
        _isCheckingBiometrics = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando estado biométrico: $e');
      }
      setState(() {
        _isCheckingBiometrics = false;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await context.read<AuthProvider>().signIn(email, password);
      
      if (success) {
        await context.read<AuthProvider>().saveCredentialsForBiometric(email, password);
        
        if (kDebugMode) {
          print('🔐 Credenciales guardadas después del login exitoso: $email');
        }
        
        await _checkBiometricStatus();
        _showSuccessModal(email);
      }
    }
  }

  void _showSuccessModal(String email) {
    final userName = email.split('@').first;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 20,
          shadowColor: _primaryColor.withOpacity(0.5),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
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
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Acceso Autorizado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  _formatUserName(userName),
                  style: TextStyle(
                    fontSize: 16,
                    color: _goldColor,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'Has accedido exitosamente a tu billetera universitaria',
                  style: TextStyle(
                    fontSize: 12,
                    color: _hintColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),
                _buildBiometricStatusIndicator(),
                
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryColor.withOpacity(0.3),
                        _cardColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _goldColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSecurityStat('Seguro', Icons.security_rounded, _accentColor),
                      _buildSecurityStat('Verificado', Icons.verified_rounded, _goldColor),
                      _buildSecurityStat('Encriptado', Icons.lock_rounded, _primaryColor),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: _backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Continuar al Dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Sesión protegida con protocolos de seguridad bancaria',
                  style: TextStyle(
                    fontSize: 10,
                    color: _hintColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiometricStatusIndicator() {
    final hasCredentials = _biometricStatus['hasCredentials'] == true;
    final isEnabled = _biometricStatus['isEnabled'] == true;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: hasCredentials && isEnabled 
            ? _accentColor.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasCredentials && isEnabled 
              ? _accentColor.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasCredentials && isEnabled 
                ? Icons.fingerprint_rounded 
                : Icons.info_outline_rounded,
            size: 13,
            color: hasCredentials && isEnabled ? _accentColor : Colors.orange,
          ),
          const SizedBox(width: 5),
          Text(
            hasCredentials && isEnabled
                ? 'Huella digital configurada ✅'
                : 'Configura huella digital para acceso rápido',
            style: TextStyle(
              fontSize: 9,
              color: hasCredentials && isEnabled ? _accentColor : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStat(String text, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1.2),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: _textColor.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatUserName(String userName) {
    if (userName.isEmpty) return 'Usuario';
    return userName[0].toUpperCase() + userName.substring(1).toLowerCase();
  }

  Future<void> _signInWithBiometric() async {
    final success = await context.read<AuthProvider>().signInWithBiometric();
    if (success) {
      final email = context.read<AuthProvider>().currentUserEmail ?? 'Usuario';
      _showSuccessModal(email);
    } else {
      final hasCredentials = _biometricStatus['hasCredentials'] == true;
      if (!hasCredentials) {
        _showNoCredentialsDialog();
      }
    }
  }

  void _showNoCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Credenciales No Encontradas',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          content: Text(
            'No hay credenciales guardadas para biometría. '
            'Inicia sesión manualmente primero para guardar tus credenciales.',
            style: TextStyle(
              color: _hintColor,
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBiometricSettings() {
    final isEnabled = _biometricStatus['isEnabled'] ?? false;
    final biometricType = _biometricStatus['biometricType'] ?? 'Biometría';
    final canAuthenticate = _biometricStatus['canAuthenticate'] ?? false;
    final hasBiometricsConfigured = _biometricStatus['hasBiometricsConfigured'] ?? false;
    final hasCredentials = _biometricStatus['hasCredentials'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 15,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _goldColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: _goldColor),
                      ),
                      child: Icon(Icons.fingerprint_rounded, size: 18, color: _goldColor),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Seguridad Biométrica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (!canAuthenticate) ...[
                  _buildStatusItem(
                    'Estado del Sistema',
                    'No Compatible',
                    Icons.error_outline_rounded,
                    Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tu dispositivo no soporta autenticación biométrica o no está configurado correctamente.',
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (!hasBiometricsConfigured) ...[
                  _buildStatusItem(
                    'Configuración Requerida',
                    'No Configurada',
                    Icons.settings_rounded,
                    Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Para usar la biometría, debes configurar al menos un método de autenticación (huella digital, rostro, etc.) en los ajustes de seguridad de tu dispositivo.',
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  _buildStatusItem(
                    'Método Disponible',
                    biometricType,
                    Icons.verified_rounded,
                    _accentColor,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildStatusItem(
                    'Estado Actual',
                    isEnabled ? 'Activado' : 'Desactivado',
                    isEnabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    isEnabled ? _accentColor : Colors.orange,
                  ),

                  const SizedBox(height: 8),
                  
                  _buildStatusItem(
                    'Credenciales Guardadas',
                    hasCredentials ? 'Sí' : 'No',
                    hasCredentials ? Icons.check_circle_rounded : Icons.warning_rounded,
                    hasCredentials ? _accentColor : Colors.orange,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _primaryColor.withOpacity(0.2),
                          _cardColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _goldColor.withOpacity(0.3)),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Habilitar Huella Digital',
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        hasCredentials 
                            ? 'Accede rápidamente con tu huella digital'
                            : 'Inicia sesión manualmente primero para guardar credenciales',
                        style: TextStyle(
                          color: hasCredentials ? _hintColor : Colors.orange,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      value: isEnabled && hasCredentials,
                      onChanged: hasCredentials ? (value) async {
                        await context.read<AuthProvider>().toggleBiometric(value);
                        Navigator.pop(context);
                        await _checkBiometricStatus();
                        
                        if (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified_rounded, color: Colors.white),
                                  const SizedBox(width: 5),
                                  const Text('Huella digital habilitada ✅'),
                                ],
                              ),
                              backgroundColor: _accentColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } : null,
                      activeColor: _accentColor,
                      inactiveTrackColor: Colors.grey.shade600,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  if (!hasCredentials) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Inicia sesión manualmente primero para guardar tus credenciales de forma segura.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor.withOpacity(0.1),
                      foregroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: _hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canUseBiometric = _biometricStatus['canAuthenticate'] == true;
    final hasBiometricsConfigured = _biometricStatus['hasBiometricsConfigured'] == true;
    final isBiometricEnabled = _biometricStatus['isEnabled'] == true;
    final hasCredentials = _biometricStatus['hasCredentials'] == true;

    final canShowBiometricButton = canUseBiometric && 
                                  hasBiometricsConfigured && 
                                  isBiometricEnabled && 
                                  hasCredentials;

    final canShowEnableButton = canUseBiometric && 
                               hasBiometricsConfigured && 
                               (!isBiometricEnabled || !hasCredentials);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    minHeight: MediaQuery.of(context).size.height - 100,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header centrado
                        _buildBankingHeader(),
                        const SizedBox(height: 20),
                        
                        // Tarjeta de login centrada
                        _buildLoginCard(),
                        
                        // Botones centrados
                        const SizedBox(height: 10),
                        _buildLoginButton(),
                        
                        if (canShowBiometricButton) ...[
                          const SizedBox(height: 8),
                          _buildFingerprintButton(),
                        ],
                        
                        if (canShowEnableButton) ...[
                          const SizedBox(height: 8),
                          _buildEnableFingerprintButton(),
                        ],
                        
                        if (canUseBiometric && !hasBiometricsConfigured) ...[
                          const SizedBox(height: 8),
                          _buildFingerprintNotConfigured(),
                        ],
                        
                        const SizedBox(height: 8),
                        _buildErrorSection(),
                        
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankingHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _primaryColor,
                    const Color(0xFF283593),
                    _accentColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: _goldColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              'Flutter Play',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _textColor,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            
            Text(
              'Inicia sesión en tu Billetera Universitaria',
              style: TextStyle(
                fontSize: 13,
                color: _hintColor,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_goldColor, _accentColor],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardColor,
            _primaryColor.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildTextField(
              controller: _emailController,
              label: 'Correo Electrónico *',
              icon: Icons.email_rounded,
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
          ),
          const SizedBox(height: 14),
          
          SizedBox(
            width: double.infinity,
            child: _buildPasswordField(
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
          ),
          
          const SizedBox(height: 14),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: _textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      keyboardType: keyboardType,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _hintColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
          borderSide: BorderSide(color: _accentColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        prefixIcon: Icon(
          icon,
          color: _hintColor,
          size: 18,
        ),
        filled: true,
        fillColor: _backgroundColor.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFormField(
          controller: controller,
          style: TextStyle(
            color: _textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          obscureText: obscureText,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: _hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
              borderSide: BorderSide(color: _accentColor, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            prefixIcon: Icon(
              Icons.lock_rounded,
              color: _hintColor,
              size: 18,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: _hintColor,
                size: 18,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: _backgroundColor.withOpacity(0.4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          validator: validator,
        ),
        
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nivel de seguridad:',
                      style: TextStyle(
                        color: _hintColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _passwordStrength,
                        key: ValueKey<String>(_passwordStrength),
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: AnimatedBuilder(
                      animation: _strengthAnimationController,
                      builder: (context, child) {
                        final animatedWidth = _strengthWidthAnimation.value * _passwordStrengthValue;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Container(
                            width: MediaQuery.of(context).size.width * animatedWidth * 0.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _passwordStrengthColor,
                                  _passwordStrengthColor.withOpacity(0.7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: _passwordStrengthColor.withOpacity(0.3),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Opacity(
                                opacity: _strengthAnimationController.value * 0.5,
                                child: Icon(
                                  _passwordStrengthValue >= 0.7
                                      ? Icons.security_rounded
                                      : _passwordStrengthValue >= 0.4
                                          ? Icons.warning_rounded
                                          : Icons.error_outline_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedOpacity(
                  opacity: _passwordController.text.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getPasswordStrengthDescription(),
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getPasswordStrengthDescription() {
    if (_passwordStrengthValue < 0.4) {
      return 'Agrega mayúsculas, números y símbolos para mejorar la seguridad';
    } else if (_passwordStrengthValue < 0.7) {
      return 'Bueno, pero considera agregar más símbolos o números';
    } else {
      return 'Excelente! Tu contraseña es muy segura';
    }
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _goldColor,
          side: BorderSide(color: _goldColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: _goldColor.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1_rounded, size: 16),
            const SizedBox(width: 6),
            Text(
              'Crear Cuenta Nueva',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFingerprintButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: authProvider.isBiometricLoading ? null : _signInWithBiometric,
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldColor.withOpacity(0.1),
              foregroundColor: _goldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: _goldColor, width: 1.2),
            ),
            child: authProvider.isBiometricLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700)),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Iniciar con Huella Digital',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEnableFingerprintButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: _showBiometricSettings,
        style: OutlinedButton.styleFrom(
          foregroundColor: _goldColor,
          side: BorderSide(color: _goldColor.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: _goldColor.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint_rounded, size: 16),
            const SizedBox(width: 6),
            Text(
              'Habilitar Huella Digital',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerprintNotConfigured() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Configura la huella digital en tu dispositivo para acceso rápido',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.error != null) {
          return SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}