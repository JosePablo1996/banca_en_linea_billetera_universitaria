import 'package:flutter/material.dart';

class WelcomeModal extends StatelessWidget {
  final String userName;
  final String biometricType;
  final VoidCallback onContinue;

  const WelcomeModal({
    super.key,
    required this.userName,
    required this.biometricType,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFE50914); // Rojo Netflix
    final Color accentColor = const Color(0xFF00FF88); // Verde neon
    final Color backgroundColor = const Color(0xFF2D2D2D);

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de éxito
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
              ),
              child: Icon(
                Icons.verified,
                size: 40,
                color: accentColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              '¡Bienvenido de vuelta!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtítulo personalizado
            Text(
              'Has iniciado sesión exitosamente con $biometricType',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Nombre de usuario
            Text(
              userName.isNotEmpty ? userName : 'Usuario',
              style: TextStyle(
                fontSize: 18,
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro Text',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Estadísticas de seguridad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSecurityStat('Seguro', Icons.security, accentColor),
                  _buildSecurityStat('Rápido', Icons.bolt, const Color(0xFFFFD700)),
                  _buildSecurityStat('Privado', Icons.lock, primaryColor),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de continuar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.5),
                ),
                child: const Text(
                  'Continuar al Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Texto informativo
            Text(
              'Tu sesión está protegida con autenticación biométrica',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStat(String text, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}