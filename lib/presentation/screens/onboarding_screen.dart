import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glassOpacityAnimation;

  final Color _primaryColor = const Color(0xFF1A237E); // Azul bancario profesional
  final Color _accentColor = const Color(0xFF00C853);  // Verde financiero
  final Color _goldColor = const Color(0xFFFFD700);    // Dorado premium
  final Color _backgroundColor = const Color(0xFF0A0E21);

  bool _showContinueButton = false;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // Inicializar partículas
    _initializeParticles();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Más suave y rápido
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _glassOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Iniciar animación después de un breve delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });

    // Mostrar botón después de las animaciones
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showContinueButton = true;
            });
          }
        });
      }
    });
  }

  void _initializeParticles() {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        size: 1.5 + Random().nextDouble() * 4,
        speed: 0.03 + Random().nextDouble() * 0.15,
        opacity: 0.2 + Random().nextDouble() * 0.6,
        horizontalSpeed: -0.08 + Random().nextDouble() * 0.16,
      ));
    }
  }

  void _updateParticles() {
    for (final particle in _particles) {
      particle.y += particle.speed * 0.006;
      particle.x += particle.horizontalSpeed * 0.006;
      
      if (particle.y > 1.2) {
        particle.y = -0.2;
        particle.x = Random().nextDouble();
      }
      if (particle.x > 1.2) {
        particle.x = -0.2;
      } else if (particle.x < -0.2) {
        particle.x = 1.2;
      }
    }
  }

  void _handleContinue() {
    setState(() {
      _showContinueButton = false;
    });
    
    // Navegar después de una animación de salida suave
    Future.delayed(const Duration(milliseconds: 600), () {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuthenticationStatus();

    if (mounted) {
      if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Fondo gradiente profesional
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF0A0E21),
                  Color(0xFF00C853),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Partículas flotantes animadas continuamente
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              _updateParticles();
              return CustomPaint(
                painter: ParticlesPainter(_particles),
                size: Size.infinite,
              );
            },
          ),
          
          // Contenido principal
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _slideAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con efecto glassmorphism
                  AnimatedBuilder(
                    animation: _glassOpacityAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryColor, _accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _accentColor.withOpacity(0.4 * _glassOpacityAnimation.value),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Efecto glassmorphism
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15 * _glassOpacityAnimation.value),
                                    Colors.white.withOpacity(0.03 * _glassOpacityAnimation.value),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Icono
                            Center(
                              child: Icon(
                                Icons.account_balance_wallet,
                                size: 60,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Título principal
                  Column(
                    children: [
                      Text(
                        'Mi Billetera',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'UNIVERSITARIA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _goldColor,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Nueva leyenda inspiradora
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Más que gastos, es tu libertad financiera.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        fontFamily: 'SF Pro Text',
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Botón Continuar con animación de entrada suave
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: _showContinueButton ? 1.0 : 0.0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 800),
                      offset: _showContinueButton ? Offset.zero : const Offset(0, 0.3),
                      child: _buildContinueButton(),
                    ),
                  ),
                  
                  // Créditos del desarrollador
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Text(
                        'Desarrollado con ❤️ por',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jose Pablo Miranda Quintanilla',
                        style: TextStyle(
                          color: _goldColor.withOpacity(0.9),
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Footer corporativo
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Tecnología Financiera Segura',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0 • 2025',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      height: 60,
      width: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _handleContinue,
          child: Stack(
            children: [
              // Efecto glassmorphism
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.03),
                    ],
                  ),
                ),
              ),
              
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase para partículas
class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double horizontalSpeed;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.horizontalSpeed,
  });
}

// Clase Random local
class Random {
  final _random = math.Random();
  
  double nextDouble() => _random.nextDouble();
}

// Pintor de partículas
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  
  ParticlesPainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      final radius = particle.size;
      
      final paint = Paint()
        ..color = const Color(0xFF00C853).withOpacity(particle.opacity * 0.3)
        ..style = PaintingStyle.fill;
      
      // Partícula principal
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
      
      // Efecto de aura suave
      canvas.drawCircle(
        Offset(x, y),
        radius * 1.8,
        paint..color = const Color(0xFF00C853).withOpacity(particle.opacity * 0.08),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return true; // Siempre repintar para animación continua
  }
}