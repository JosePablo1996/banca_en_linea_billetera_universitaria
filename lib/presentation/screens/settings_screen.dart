import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color backgroundColor = Color(0xFF0D0D0D);
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color primaryColor = Color(0xFFE50914);
  static const Color accentColor = Color(0xFF00FF88);
  static const Color secondaryAccent = Color(0xFF0099FF);
  
  late TextEditingController _budgetController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Configuración',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'SF Pro Display',
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(0, 0, 0, 0.95),
              Color.fromRGBO(0, 0, 0, 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(0, 255, 136, 0.3),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // TEMPORAL: Mientras se agrega el campo budget al modelo
        final currentBudget = 1000.0; // Valor temporal
        
        // Actualizar el controlador si no está en modo edición
        if (!_isEditing && _budgetController.text.isEmpty) {
          _budgetController.text = currentBudget.toStringAsFixed(2);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetSection(currentBudget, profileProvider),
              const SizedBox(height: 24),
              _buildOtherSettings(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetSection(double currentBudget, ProfileProvider profileProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Presupuesto Mensual',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 255, 136, 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color.fromRGBO(0, 255, 136, 0.3)),
                ),
                child: const Text(
                  'Configurable',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_isEditing)
            _buildBudgetDisplay(currentBudget)
          else
            _buildBudgetEditForm(profileProvider),
          
          const SizedBox(height: 20),
          
          if (!_isEditing)
            _buildEditButton()
          else
            _buildSaveCancelButtons(profileProvider),
        ],
      ),
    );
  }

  Widget _buildBudgetDisplay(double currentBudget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Color(0xFF00FF88), size: 24),
            SizedBox(width: 12),
            Text(
              'Presupuesto actual:',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(255, 255, 255, 0.8),
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(0, 255, 136, 0.1),
                Color.fromRGBO(0, 255, 136, 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color.fromRGBO(0, 255, 136, 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00FF88),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currentBudget.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00FF88),
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Este es el límite máximo que tienes para gastos mensuales. '
          'Recibirás notificaciones cuando te acerques al límite.',
          style: TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(255, 255, 255, 0.6),
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetEditForm(ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nuevo presupuesto mensual:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _budgetController,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00FF88),
            fontFamily: 'SF Pro Display',
          ),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              fontSize: 24,
              color: Color(0xFF00FF88),
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: const Color.fromRGBO(0, 0, 0, 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color.fromRGBO(0, 255, 136, 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color.fromRGBO(0, 255, 136, 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00FF88)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa el nuevo monto en dólares (ej: 1200.50)',
          style: TextStyle(
            fontSize: 12,
            color: Color.fromRGBO(255, 255, 255, 0.5),
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Row(
      children: [
        Expanded(
          child: _buildNeonButton(
            text: 'Editar Presupuesto',
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            color: accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNeonButton(
            text: 'Restablecer a \$1000',
            onPressed: () {
              _budgetController.text = '1000.00';
              // Aquí guardaremos el cambio en el provider
            },
            color: secondaryAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveCancelButtons(ProfileProvider profileProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildNeonButton(
            text: 'Cancelar',
            onPressed: () {
              setState(() {
                _isEditing = false;
                // Restaurar valor original
                _budgetController.text = '1000.0'; // Valor temporal
              });
            },
            color: const Color.fromRGBO(255, 255, 255, 0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNeonButton(
            text: 'Guardar',
            onPressed: () {
              final newBudget = double.tryParse(_budgetController.text) ?? 1000.0;
              
              // Aquí actualizaremos el provider
              // profileProvider.updateBudget(newBudget);
              
              setState(() {
                _isEditing = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF00FF88)),
                      const SizedBox(width: 10),
                      Text('Presupuesto actualizado a \$${newBudget.toStringAsFixed(2)}'),
                    ],
                  ),
                  backgroundColor: cardColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color.fromRGBO(0, 255, 136, 0.3)),
                  ),
                ),
              );
            },
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Otras Configuraciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsOption(
            'Notificaciones',
            'Recibir alertas sobre tus gastos',
            Icons.notifications_active,
            secondaryAccent,
            true,
          ),
          _buildSettingsOption(
            'Tema de la App',
            'Cambiar entre claro y oscuro',
            Icons.color_lens,
            primaryColor,
            false,
          ),
          _buildSettingsOption(
            'Exportar Datos',
            'Descargar tu historial de gastos',
            Icons.file_download,
            accentColor,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(String title, String subtitle, IconData icon, Color color, bool isActive) {
    // Extraer componentes RGB del color
    final int red = (color.red * 255).round().clamp(0, 255);
    final int green = (color.green * 255).round().clamp(0, 255);
    final int blue = (color.blue * 255).round().clamp(0, 255);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(red, green, blue, 0.1),
            Color.fromRGBO(red, green, blue, 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color.fromRGBO(red, green, blue, 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(red, green, blue, 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color.fromRGBO(red, green, blue, 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              // Implementar lógica del switch
            },
            activeThumbColor: color,
            activeTrackColor: Color.fromRGBO(red, green, blue, 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonButton({required String text, required VoidCallback onPressed, required Color color}) {
    // Extraer componentes RGB del color
    final int red = (color.red * 255).round().clamp(0, 255);
    final int green = (color.green * 255).round().clamp(0, 255);
    final int blue = (color.blue * 255).round().clamp(0, 255);
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(red, green, blue, 0.2),
              Color.fromRGBO(red, green, blue, 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color.fromRGBO(red, green, blue, 0.5)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(red, green, blue, 0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
    );
  }
}