import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/expenses_screen.dart';
import '../screens/profile_screen.dart';

class DashboardHeader extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
  
  final AnimationController animationController;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color accentColor;
  final Color secondaryAccent;
  final Color goldColor;
  final VoidCallback onRefresh;
  final VoidCallback onShowNotifications;

  const DashboardHeader({
    super.key,
    required this.animationController,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.accentColor,
    required this.secondaryAccent,
    required this.goldColor,
    required this.onRefresh,
    required this.onShowNotifications,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _bellController;
  late Animation<double> _bellShakeAnimation;
  
  // Colores neon saturados rojo-verde
  final Color _neonRed = const Color(0xFFFF1744);
  final Color _neonGreen = const Color(0xFF00E676);
  final Color _neonBlue = const Color(0xFF2979FF);
  final Color _neonPurple = const Color(0xFFD500F9);
  final Color _neonYellow = const Color(0xFFFFEA00);
  final Color _neonCyan = const Color(0xFF18FFFF);

  @override
  void initState() {
    super.initState();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Animación de campana que se agita
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _bellShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -0.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -0.2, end: 0.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bellController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  void _startBellAnimation() {
    if (_bellController.isAnimating) {
      _bellController.reset();
    }
    _bellController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: false,
      flexibleSpace: _buildNeonBackground(),
      actions: [
        _buildNotificationBadge(),
        const SizedBox(width: 12),
        _buildUserMenu(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNeonBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.95),
            Colors.black.withOpacity(0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: _neonRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _neonRed.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _neonGreen.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    _neonRed.withOpacity(0.1),
                    _neonGreen.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: _neonRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: _neonGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mi Billetera',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      fontFamily: 'SF Pro Display',
                      shadows: [
                        Shadow(
                          color: _neonGreen.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserMenu() {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        final user = authProvider.currentUser;
        final profile = profileProvider.profile;
        
        final userName = profile?.fullName ?? 
                        user?.userMetadata?['full_name'] as String? ?? 
                        user?.email?.split('@').first ?? 
                        'Usuario';
        
        final avatarUrl = profile?.avatarUrl ?? 
                         user?.userMetadata?['avatar_url'] as String?;
        
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: PopupMenuButton<String>(
            icon: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_neonRed, _neonGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonRed.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _neonGreen.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  _buildAvatarImage(
                    avatarUrl: avatarUrl,
                    size: 44,
                    iconSize: 20,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            color: const Color(0xFF0A0A0A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(
                color: _neonRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            surfaceTintColor: const Color(0xFF0A0A0A),
            elevation: 20,
            shadowColor: _neonRed.withOpacity(0.5),
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: GestureDetector(
                    onTap: () => _showAvatarModal(context, avatarUrl, userName),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            const Color(0xFF111111),
                          ],
                        ),
                        border: Border.all(
                          color: _neonRed.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _neonGreen.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showAvatarModal(context, avatarUrl, userName),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [_neonRed, _neonGreen],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _neonRed.withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  _buildAvatarImage(
                                    avatarUrl: avatarUrl,
                                    size: 54,
                                    iconSize: 24,
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'SF Pro Display',
                                    shadows: [
                                      Shadow(
                                        color: _neonGreen.withOpacity(0.3),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Controla tus gastos',
                                  style: TextStyle(
                                    color: _neonGreen.withOpacity(0.8),
                                    fontSize: 13,
                                    fontFamily: 'SF Pro Text',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.visibility,
                            color: _neonGreen.withOpacity(0.7),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const PopupMenuDivider(height: 20),
              _buildNeonMenuItem(
                'expenses',
                'Todos los Gastos',
                Icons.list_alt,
                _neonGreen,
              ),
              _buildNeonMenuItem(
                'profile',
                'Mi Perfil',
                Icons.person_outline,
                _neonYellow,
              ),
              _buildNeonMenuItem(
                'stats',
                'Estadísticas',
                Icons.analytics_outlined,
                _neonPurple,
              ),
              const PopupMenuDivider(height: 20),
              _buildNeonMenuItem(
                'delete_all',
                'Limpiar Gastos',
                Icons.delete_sweep,
                _neonRed,
              ),
              const PopupMenuDivider(height: 20),
              _buildNeonMenuItem(
                'logout',
                'Cerrar Sesión',
                Icons.logout,
                _neonRed,
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarImage({
    required String? avatarUrl,
    required double size,
    required double iconSize,
  }) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      final String imageUrl = avatarUrl.startsWith('http') 
          ? avatarUrl 
          : _getFullImageUrl(avatarUrl);
      
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_neonRed, _neonGreen],
                ),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: iconSize,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_neonRed, _neonGreen],
                  ),
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [_neonRed, _neonGreen],
          ),
        ),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: iconSize,
        ),
      );
    }
  }

  String _getFullImageUrl(String fileName) {
    final baseUrl = 'https://your-project-ref.supabase.co/storage/v1/object/public/avatars';
    return '$baseUrl/profiles/$fileName';
  }

  PopupMenuItem<String> _buildNeonMenuItem(String value, String text, IconData icon, Color color, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () => _handleMenuSelection(value, context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.05),
                  color.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(isDestructive ? 0.4 : 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isDestructive ? 0.15 : 0.1),
                  blurRadius: isDestructive ? 15 : 8,
                  spreadRadius: isDestructive ? 1 : 0.5,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(isDestructive ? 0.5 : 0.3),
                      width: isDestructive ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(isDestructive ? 0.4 : 0.2),
                        blurRadius: 10,
                        spreadRadius: isDestructive ? 2 : 1,
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.3),
                        color.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isDestructive ? 20 : 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isDestructive ? color : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: isDestructive ? 0.3 : 0.2,
                      shadows: isDestructive ? [
                        Shadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ] : null,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    // Cerrar el menú primero
    Navigator.pop(context);
    
    // Ejecutar la acción correspondiente
    switch (value) {
      case 'expenses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpensesScreen()),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'stats':
        _showStats(context);
        break;
      case 'delete_all':
        _showDeleteAllDialog(context);
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  Widget _buildNotificationBadge() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recentExpensesCount = expenseProvider.recentExpenses.length;
        final todayExpensesCount = expenseProvider.todayExpenses.length;
        
        final hasNotifications = recentExpensesCount > 0 || todayExpensesCount > 0;
        
        // Iniciar animación si hay notificaciones
        if (hasNotifications && !_bellController.isAnimating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startBellAnimation();
          });
        }
        
        if (!hasNotifications) {
          return IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: _neonGreen.withOpacity(0.6),
            ),
            onPressed: widget.onShowNotifications,
          );
        }
        
        return Stack(
          children: [
            AnimatedBuilder(
              animation: _bellShakeAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _bellShakeAnimation.value,
                  child: child,
                );
              },
              child: IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: _neonRed,
                ),
                onPressed: () {
                  widget.onShowNotifications();
                  _startBellAnimation();
                },
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _neonRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _neonRed.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: _neonRed.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  (recentExpensesCount + todayExpensesCount).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNeonButton({required String text, required VoidCallback onPressed, required Color color, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDestructive
                ? [color.withOpacity(0.3), color.withOpacity(0.15)]
                : [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(isDestructive ? 0.8 : 0.4),
            width: isDestructive ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDestructive ? 0.4 : 0.2),
              blurRadius: isDestructive ? 20 : 15,
              spreadRadius: isDestructive ? 3 : 1,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarModal(BuildContext context, String? avatarUrl, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_neonRed, _neonGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _neonRed.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: _neonGreen.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl.startsWith('http') 
                                  ? avatarUrl 
                                  : _getFullImageUrl(avatarUrl),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: _neonGreen,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 80,
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 80,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      shadows: [
                        Shadow(
                          color: _neonGreen.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Toca para cerrar',
                    style: TextStyle(
                      fontSize: 14,
                      color: _neonGreen.withOpacity(0.8),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStats(BuildContext context) {
    final expenseProvider = context.read<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: _neonGreen),
              const SizedBox(width: 10),
              const Text('No hay gastos para mostrar estadísticas'),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: _neonGreen.withOpacity(0.3)),
          ),
        ),
      );
      return;
    }

    final totalAmount = expenseProvider.totalExpenses;
    final averageAmount = expenseProvider.averageAmount;
    final largestExpense = expenseProvider.largestExpense;
    final currentMonthTotal = expenseProvider.currentMonthExpenses.fold(
      0.0, (sum, expense) => sum + expense.amount);
    final todayTotal = expenseProvider.todayExpenses.fold(
      0.0, (sum, expense) => sum + expense.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: _neonGreen.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: _neonGreen.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _neonGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [_neonRed, _neonGreen],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.analytics, color: _neonPurple),
                    const SizedBox(width: 12),
                    Text(
                      'Estadísticas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Resumen completo de tus gastos',
                  style: TextStyle(
                    fontSize: 14,
                    color: _neonGreen.withOpacity(0.8),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 25),
                _buildStatItemRow('Total de gastos:', '\$${totalAmount.toStringAsFixed(2)}', _neonGreen),
                _buildStatItemRow('Número de gastos:', '${expenses.length}', _neonCyan),
                _buildStatItemRow('Gasto promedio:', '\$${averageAmount.toStringAsFixed(2)}', _neonYellow),
                _buildStatItemRow('Gasto más grande:', largestExpense != null 
                    ? '\$${largestExpense.amount.toStringAsFixed(2)}'
                    : 'N/A', _neonRed),
                _buildStatItemRow('Gastos este mes:', '\$${currentMonthTotal.toStringAsFixed(2)}', _neonPurple),
                _buildStatItemRow('Gastos de hoy:', '\$${todayTotal.toStringAsFixed(2)}', _neonBlue),
                const SizedBox(height: 30),
                _buildNeonButton(
                  text: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  color: _neonGreen,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItemRow(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: valueColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Text',
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: valueColor.withOpacity(0.3)),
              gradient: LinearGradient(
                colors: [
                  valueColor.withOpacity(0.05),
                  valueColor.withOpacity(0.02),
                ],
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
                fontFamily: 'SF Pro Display',
                shadows: [
                  Shadow(
                    color: valueColor.withOpacity(0.3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    final expenseProvider = context.read<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: _neonGreen),
              const SizedBox(width: 10),
              const Text('No hay gastos para eliminar'),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: _neonGreen.withOpacity(0.3)),
          ),
        ),
      );
      return;
    }

    final totalAmount = expenseProvider.totalExpenses;
    final currentMonthTotal = expenseProvider.currentMonthExpenses.fold(
      0.0, (sum, expense) => sum + expense.amount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _neonRed.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: _neonRed.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _neonRed.withOpacity(0.8),
                          _neonRed.withOpacity(0.3),
                        ],
                      ),
                      border: Border.all(
                        color: _neonRed.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.delete_forever,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Eliminar Todos los Gastos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '¿Estás seguro de que quieres eliminar\nlos ${expenses.length} gastos?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _neonRed.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildStatItemRow('Total de gastos:', '\$${totalAmount.toStringAsFixed(2)}', _neonRed),
                        const SizedBox(height: 10),
                        _buildStatItemRow('Número de gastos:', '${expenses.length}', _neonRed),
                        const SizedBox(height: 10),
                        _buildStatItemRow('Gastos este mes:', '\$${currentMonthTotal.toStringAsFixed(2)}', _neonRed),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNeonButton(
                          text: 'Cancelar',
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNeonButton(
                          text: 'ELIMINAR',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteAllExpenses(context, expenseProvider);
                          },
                          color: _neonRed,
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteAllExpenses(BuildContext context, ExpenseProvider expenseProvider) {
    expenseProvider.deleteAllExpenses().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: _neonGreen),
              const SizedBox(width: 12),
              const Expanded(child: Text('Todos los gastos han sido eliminados')),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: _neonRed.withOpacity(0.3)),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: _neonGreen,
            onPressed: () {},
          ),
        ),
      );
    });
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    
    final user = authProvider.currentUser;
    final profile = profileProvider.profile;
    
    final userName = profile?.fullName ?? 
                    user?.userMetadata?['full_name'] as String? ?? 
                    user?.email?.split('@').first ?? 
                    'Usuario';
    
    final avatarUrl = profile?.avatarUrl ?? 
                     user?.userMetadata?['avatar_url'] as String?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _neonRed.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: _neonRed.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: _neonGreen.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarModal(context, avatarUrl, userName),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_neonRed, _neonGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _neonRed.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                          BoxShadow(
                            color: _neonGreen.withOpacity(0.3),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          _buildAvatarImage(
                            avatarUrl: avatarUrl,
                            size: 94,
                            iconSize: 40,
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _neonGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _neonGreen.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '¿Listo para cerrar sesión?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _neonRed.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNeonButton(
                          text: 'Cancelar',
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNeonButton(
                          text: 'Cerrar Sesión',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _logout(context);
                          },
                          color: _neonRed,
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().signOut();
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false
    );
  }
}