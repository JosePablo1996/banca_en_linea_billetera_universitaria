import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expenseToEdit;
  
  const AddExpenseScreen({
    super.key,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  
  String _recurrencePattern = 'monthly';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Colores neon saturados
  final Color _neonRed = const Color(0xFFFF1744);
  final Color _neonGreen = const Color(0xFF00E676);
  final Color _neonBlue = const Color(0xFF2979FF);
  final Color _neonPurple = const Color(0xFFD500F9);
  final Color _neonYellow = const Color(0xFFFFEA00);
  final Color _neonCyan = const Color(0xFF18FFFF);
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardColor = const Color(0xFF1A1A1A);

  final Map<ExpenseCategory, double> _categoryBudgets = {
    ExpenseCategory.food: 1000.0,
    ExpenseCategory.transport: 500.0,
    ExpenseCategory.materials: 400.0,
    ExpenseCategory.tuition: 300.0,
    ExpenseCategory.housing: 800.0,
    ExpenseCategory.entertainment: 300.0,
    ExpenseCategory.health: 200.0,
    ExpenseCategory.other: 200.0,
  };

  final List<Map<String, dynamic>> _recurrenceOptions = [
    {'value': 'daily', 'displayName': 'Diario', 'color': Colors.cyan},
    {'value': 'weekly', 'displayName': 'Semanal', 'color': Colors.green},
    {'value': 'monthly', 'displayName': 'Mensual', 'color': Colors.blue},
    {'value': 'yearly', 'displayName': 'Anual', 'color': Colors.purple},
  ];

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
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Cargar datos si estamos en modo edición
    if (widget.expenseToEdit != null) {
      _loadExpenseData(widget.expenseToEdit!);
    }
    
    _animationController.forward();
  }

  void _loadExpenseData(ExpenseModel expense) {
    _nameController.text = expense.name;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _selectedCategory = expense.category;
    _selectedDate = expense.date;
    _isRecurring = expense.isRecurring;
    _recurrencePattern = expense.recurrencePattern ?? 'monthly';
    _descriptionController.text = expense.description ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _neonGreen,
              onPrimary: Colors.black,
              surface: const Color(0xFF0A0A0A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0A0A0A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSuccessModal({bool isEdit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _cardColor.withOpacity(0.8),
                  Colors.black.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _neonGreen.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: _neonGreen.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
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
                        colors: [_neonGreen, _neonCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _neonGreen.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  Text(
                    '¡Éxito!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _neonGreen,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: _neonGreen.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    isEdit 
                      ? 'Gasto actualizado correctamente'
                      : 'Gasto registrado correctamente',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _neonGreen.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\$${_amountController.text}',
                              style: TextStyle(
                                color: _neonGreen,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'SF Pro Display',
                                shadows: [
                                  Shadow(
                                    color: _neonGreen.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(_selectedCategory.colorValue).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(_selectedCategory.colorValue).withOpacity(0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(_selectedCategory.colorValue).withOpacity(0.2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                _selectedCategory.displayName,
                                style: TextStyle(
                                  color: Color(_selectedCategory.colorValue),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildNeonButton(
                    text: isEdit ? 'Volver al Dashboard' : 'Continuar',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    color: _neonGreen,
                    isLarge: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final expenseProvider = context.read<ExpenseProvider>();
      final authProvider = context.read<AuthProvider>();
      
      final userId = authProvider.userId;
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      final isEditing = widget.expenseToEdit != null;
      
      if (isEditing) {
        final updatedExpense = widget.expenseToEdit!.copyWith(
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          category: _selectedCategory,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          isRecurring: _isRecurring,
          recurrencePattern: _isRecurring ? _recurrencePattern : null,
          updatedAt: DateTime.now(),
        );

        await expenseProvider.updateExpense(updatedExpense);
        _showSuccessModal(isEdit: true);
        
      } else {
        final expense = ExpenseModel(
          id: '',
          userId: userId,
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          category: _selectedCategory,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          receiptUrl: null,
          isRecurring: _isRecurring,
          recurrencePattern: _isRecurring ? _recurrencePattern : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (expenseProvider.hasDuplicateExpense(expense)) {
          throw Exception('Ya existe un gasto similar con el mismo nombre, monto y fecha');
        }

        await expenseProvider.addExpense(expense);
        _showSuccessModal(isEdit: false);
      }
      
    } catch (error) {
      print('❌ Error al ${widget.expenseToEdit != null ? 'actualizar' : 'agregar'} gasto: $error');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: _neonRed),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $error')),
              ],
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: _neonRed.withOpacity(0.3)),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: _neonGreen,
              onPressed: _submitExpense,
            ),
          ),
        );
      }
    }
  }

  double _getRemainingBudget() {
    final budget = _categoryBudgets[_selectedCategory] ?? 0.0;
    final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
    return budget - currentAmount;
  }

  Color _getBudgetColor(double remaining) {
    if (remaining < 0) return _neonRed;
    if (remaining < 50) return _neonYellow;
    return _neonGreen;
  }

  Widget _buildCategoryCard(ExpenseCategory category) {
    final isSelected = _selectedCategory == category;
    final categoryColor = Color(category.colorValue);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.8),
                    categoryColor.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? categoryColor.withOpacity(0.8) : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              category.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    bool isAmount = false,
    bool isDate = false,
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _neonBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _neonBlue.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _neonBlue.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: _neonBlue, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _neonBlue.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _neonBlue.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _neonBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _neonRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _neonRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: TextStyle(
            color: _neonRed,
            fontSize: 12,
            fontFamily: 'SF Pro Text',
          ),
          prefixText: isAmount ? '\$ ' : null,
          prefixStyle: const TextStyle(color: Colors.white),
        ),
        validator: validator,
        onTap: onTap,
        readOnly: isDate,
        keyboardType: isAmount ? TextInputType.numberWithOptions(decimal: true) : null,
        onChanged: (value) {
          if (isAmount) setState(() {});
        },
      ),
    );
  }

  Widget _buildNeonButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: isLarge
            ? const EdgeInsets.symmetric(horizontal: 32, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(isLarge ? 18 : 15),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: color,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.expenseToEdit != null ? Icons.update : Icons.add_circle_outline,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: isLarge ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingBudget = _getRemainingBudget();
    final budgetColor = _getBudgetColor(remainingBudget);
    final isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add_circle_outline,
                      color: _neonGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Editar Gasto' : 'Agregar Gasto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        centerTitle: false,
        flexibleSpace: Container(
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
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_neonGreen, _neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _neonGreen.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                isEditing ? Icons.save : Icons.save_alt,
                size: 20,
                color: Colors.white,
              ),
              onPressed: _submitExpense,
              tooltip: isEditing ? 'Actualizar gasto' : 'Guardar gasto',
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Presupuesto restante
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimation.value, 0),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _cardColor.withOpacity(0.8),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: budgetColor.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: budgetColor.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRESUPUESTO RESTANTE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Text',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '\$${remainingBudget.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: budgetColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'SF Pro Display',
                                shadows: [
                                  Shadow(
                                    blurRadius: 15,
                                    color: budgetColor.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'de \$${_categoryBudgets[_selectedCategory]?.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 15,
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                          ],
                        ),
                        if (remainingBudget < 0)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _neonRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _neonRed.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: _neonRed, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Has excedido tu presupuesto',
                                  style: TextStyle(
                                    color: _neonRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre del gasto
                _buildNeonTextField(
                  label: 'Nombre del gasto *',
                  icon: Icons.shopping_cart,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Monto
                _buildNeonTextField(
                  label: 'Monto *',
                  icon: Icons.attach_money,
                  controller: _amountController,
                  isAmount: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Por favor ingresa un monto válido mayor a 0';
                    }
                    if (amount > 1000000) {
                      return 'El monto no puede ser mayor a \$1,000,000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Categorías
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimation.value, 0),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATEGORÍA *',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: ExpenseCategory.values.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(ExpenseCategory.values[index]);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fecha
                _buildNeonTextField(
                  label: 'Fecha *',
                  icon: Icons.calendar_today,
                  controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                  isDate: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona una fecha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descripción
                _buildNeonTextField(
                  label: 'Descripción (opcional)',
                  icon: Icons.description,
                  controller: _descriptionController,
                  validator: null,
                ),
                const SizedBox(height: 16),

                // Gasto recurrente
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimation.value, 0),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _cardColor.withOpacity(0.8),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: _neonPurple.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: _neonPurple.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _neonPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _neonPurple.withOpacity(0.4)),
                              ),
                              child: Icon(Icons.repeat, size: 20, color: _neonPurple),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'GASTO RECURRENTE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: Text(
                            'Habilitar gasto recurrente',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                          subtitle: Text(
                            'Ej: Mensual, semanal, etc.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontFamily: 'SF Pro Text',
                            ),
                          ),
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() {
                              _isRecurring = value;
                            });
                          },
                          secondary: Icon(Icons.repeat, color: _neonPurple),
                          activeColor: _neonPurple,
                          tileColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        if (_isRecurring) ...[
                          const SizedBox(height: 16),
                          Text(
                            'FRECUENCIA',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Text',
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _recurrencePattern,
                            dropdownColor: const Color(0xFF0A0A0A),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: _neonPurple.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: _neonPurple.withOpacity(0.2)),
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _recurrenceOptions.map<DropdownMenuItem<String>>((option) {
                              return DropdownMenuItem<String>(
                                value: option['value'] as String,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: (option['color'] as Color).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: (option['color'] as Color).withOpacity(0.4)),
                                      ),
                                      child: Icon(
                                        option['value'] == 'daily' ? Icons.today :
                                        option['value'] == 'weekly' ? Icons.date_range :
                                        option['value'] == 'monthly' ? Icons.calendar_today :
                                        Icons.calendar_view_month,
                                        size: 16,
                                        color: option['color'] as Color,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      option['displayName'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _recurrencePattern = value!;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de enviar
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimation.value, 0),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildNeonButton(
                    text: isEditing ? 'Actualizar Gasto' : 'Agregar Gasto',
                    onPressed: _submitExpense,
                    color: _neonGreen,
                    isLarge: true,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}