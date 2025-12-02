import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/sort_option.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_grid_card.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  final Color _primaryColor = const Color(0xFFE50914);
  final Color _backgroundColor = const Color(0xFF0D0D0D);
  final Color _cardColor = const Color(0xFF1A1A1A);
  final Color _accentColor = const Color(0xFF00FF88);
  final Color _secondaryColor = const Color(0xFF4A6FFF);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isGridView = false;
  SortOption _currentSort = SortOption.dateDesc;

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
    
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
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
      appBar: AppBar(
        title: const Text(
          'Gestión de Gastos',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'SF Pro Display',
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withOpacity(0.3),
                  _primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryColor.withOpacity(0.4)),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor.withOpacity(0.3),
                    _accentColor.withOpacity(0.1),
                ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentColor.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.add_chart, color: Colors.white, size: 20),
            ),
            onPressed: () => _addNewExpense(context),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          List<ExpenseModel> expenses = _getSortedExpenses(expenseProvider.expenses);

          if (expenseProvider.isLoading && expenses.isEmpty) {
            return _buildLoadingState();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de controles
                  _buildControlsBar(),
                  const SizedBox(height: 16),
                  
                  // Header con contador
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: _buildHeader(expenses.length),
                  ),
                  const SizedBox(height: 20),
                  
                  // Estadísticas mejoradas
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: _buildEnhancedStats(expenses),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título de la lista
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _isGridView ? 'Gastos en Cuadrícula' : 'Lista de Gastos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'SF Pro Display',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _secondaryColor.withOpacity(0.2),
                                _secondaryColor.withOpacity(0.1),
                            ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _secondaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${expenses.length} items',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _secondaryColor,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista o Grid de gastos
                  Expanded(
                    child: expenses.isEmpty 
                      ? _buildEmptyState()
                      : _isGridView
                          ? _buildGridView(expenses, expenseProvider)
                          : _buildListView(expenses, expenseProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withOpacity(0.8),
            _cardColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Selector de ordenamiento
          Expanded(
            child: GestureDetector(
              onTap: _showSortOptions,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: double.infinity,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryColor.withOpacity(0.15),
                      _primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(_currentSort.icon, size: 18, color: _primaryColor),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _currentSort.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: 'SF Pro Text',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: _primaryColor.withOpacity(0.7)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Botón de vista
          GestureDetector(
            onTap: () {
              setState(() {
                _isGridView = !_isGridView;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isGridView 
                      ? 'Cambiando a vista de cuadrícula'
                      : 'Cambiando a vista de lista',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: _secondaryColor,
                  behavior: SnackBarBehavior.fixed, // ✅ CORREGIDO: Cambiado de floating a fixed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _secondaryColor.withOpacity(0.3),
                    _secondaryColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _secondaryColor.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _isGridView ? Icons.list : Icons.grid_view,
                color: _secondaryColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int expenseCount) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.15),
            _accentColor.withOpacity(0.1),
            _secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Dashboard Financiero',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    'Control total de tus gastos y finanzas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'SF Pro Text',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryColor.withOpacity(0.4),
                    _primaryColor.withOpacity(0.2),
                ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _primaryColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$expenseCount',
                    style: TextStyle(
                      fontSize: 24,
                      color: _primaryColor,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'SF Pro Display',
                      shadows: [
                        Shadow(
                          color: _primaryColor.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'gastos',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStats(List<ExpenseModel> expenses) {
    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final today = DateTime.now();
    final todayExpenses = expenses.where((expense) => 
      expense.date.year == today.year &&
      expense.date.month == today.month &&
      expense.date.day == today.day
    ).toList();
    final todayAmount = todayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekExpenses = expenses.where((expense) => 
      expense.date.isAfter(weekAgo)
    ).toList();
    final weekAmount = weekExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withOpacity(0.9),
            _cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: _buildEnhancedStatItem(
              value: '\$${totalAmount.toStringAsFixed(2)}',
              label: 'Total General',
              icon: Icons.account_balance_wallet,
              color: _accentColor,
              description: 'Suma de todos los gastos',
            ),
          ),
          Flexible(
            child: _buildEnhancedStatItem(
              value: '\$${todayAmount.toStringAsFixed(2)}',
              label: 'Gasto Hoy',
              icon: Icons.today,
              color: _primaryColor,
              description: '${todayExpenses.length} transacciones',
            ),
          ),
          Flexible(
            child: _buildEnhancedStatItem(
              value: '\$${weekAmount.toStringAsFixed(2)}',
              label: 'Última Semana',
              icon: Icons.calendar_view_week,
              color: _secondaryColor,
              description: '${weekExpenses.length} gastos',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.4),
                color.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'SF Pro Display',
              shadows: [
                Shadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            fontFamily: 'SF Pro Display',
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.5),
            fontFamily: 'SF Pro Text',
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildListView(List<ExpenseModel> expenses, ExpenseProvider expenseProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: ListView.separated(
        key: ValueKey(_currentSort),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: expenses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return AnimatedOpacity(
            duration: Duration(milliseconds: 300 + (index * 100)),
            opacity: 1.0,
            child: ExpenseCard(
              expense: expense,
              onEdit: () => _editExpense(context, expense, expenseProvider),
              onDelete: () => _showDeleteDialog(context, expense, expenseProvider),
              primaryColor: _primaryColor,
              backgroundColor: _cardColor,
              accentColor: _accentColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<ExpenseModel> expenses, ExpenseProvider expenseProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: GridView.builder(
        key: ValueKey(_currentSort),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return AnimatedOpacity(
            duration: Duration(milliseconds: 300 + (index * 100)),
            opacity: 1.0,
            child: ExpenseGridCard(
              expense: expense,
              onTap: () => _showExpenseDetails(context, expense, expenseProvider),
              onEdit: () => _editExpense(context, expense, expenseProvider),
              onDelete: () => _showDeleteDialog(context, expense, expenseProvider),
              primaryColor: _primaryColor,
              backgroundColor: _cardColor,
              accentColor: _accentColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor.withOpacity(0.4),
                    _accentColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: _accentColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      color: _accentColor,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: _accentColor.withOpacity(0.8),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Optimizando tu dashboard...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Cargando datos financieros y estadísticas para una gestión más inteligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accentColor.withOpacity(0.15),
                      _accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(color: _accentColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pie_chart_outline,
                  size: 60,
                  color: _accentColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '¡Tu dashboard está listo!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Comienza agregando tu primer gasto para desbloquear todas las estadísticas y herramientas de análisis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: 'SF Pro Text',
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildEnhancedNeonButton(
                text: 'Agregar Primer Gasto',
                icon: Icons.add,
                onPressed: () => _addNewExpense(context),
                color: _accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewExpense(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Redirigiendo al formulario de nuevo gasto...',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _accentColor,
        behavior: SnackBarBehavior.fixed, // ✅ CORREGIDO: Cambiado de floating a fixed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }

  void _editExpense(BuildContext context, ExpenseModel expense, ExpenseProvider expenseProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.edit, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Editando "${expense.name}"...',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.fixed, // ✅ CORREGIDO: Cambiado de floating a fixed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(milliseconds: 1500),
        showCloseIcon: true,
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, ExpenseModel expense, ExpenseProvider expenseProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true, // ✅ AÑADIDO: Para permitir scroll
      builder: (context) {
        return DraggableScrollableSheet( // ✅ CORREGIDO: Usar DraggableScrollableSheet
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cardColor,
                    _cardColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Detalles del Gasto',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor(expense.category).withOpacity(0.2),
                                  _getCategoryColor(expense.category).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getCategoryColor(expense.category).withOpacity(0.3)),
                            ),
                            child: Text(
                              expense.category.displayName,
                              style: TextStyle(
                                color: _getCategoryColor(expense.category),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildExpenseDetailsContent(expense),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseDetailsContent(ExpenseModel expense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre y monto
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                expense.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor.withOpacity(0.3),
                    _accentColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentColor.withOpacity(0.4)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _accentColor,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Información detallada
        _buildDetailItem(
          icon: Icons.category,
          label: 'Categoría',
          value: expense.category.displayName,
          color: _getCategoryColor(expense.category),
        ),
        const SizedBox(height: 12),
        
        _buildDetailItem(
          icon: Icons.calendar_today,
          label: 'Fecha',
          value: expense.formattedDate,
          color: Colors.white.withOpacity(0.7),
        ),
        const SizedBox(height: 12),
        
        if (expense.isRecurring && expense.recurrenceDisplayName != null)
          Column(
            children: [
              _buildDetailItem(
                icon: expense.recurrenceIcon ?? Icons.repeat,
                label: 'Recurrencia',
                value: expense.recurrenceDisplayName!,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
            ],
          ),
        
        if (expense.description != null && expense.description!.isNotEmpty)
          Column(
            children: [
              _buildDetailItem(
                icon: Icons.description,
                label: 'Descripción',
                value: expense.description!,
                color: Colors.white.withOpacity(0.7),
                multiLine: true,
              ),
              const SizedBox(height: 12),
            ],
          ),
        
        if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty)
          Column(
            children: [
              _buildDetailItem(
                icon: Icons.receipt,
                label: 'Comprobante',
                value: 'Adjunto disponible',
                color: Colors.blue,
                isLink: true,
              ),
              const SizedBox(height: 12),
            ],
          ),
        
        const SizedBox(height: 20),
        Text(
          'Información del registro',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _buildDetailItem(
              icon: Icons.add_box,
              label: 'Creado',
              value: '${expense.createdAt.day}/${expense.createdAt.month}/${expense.createdAt.year}',
              color: Colors.white.withOpacity(0.5),
              small: true,
            ),
            _buildDetailItem(
              icon: Icons.update,
              label: 'Actualizado',
              value: '${expense.updatedAt.day}/${expense.updatedAt.month}/${expense.updatedAt.year}',
              color: Colors.white.withOpacity(0.5),
              small: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool multiLine = false,
    bool isLink = false,
    bool small = false,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: small ? 16 : 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: small ? 10 : 12,
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 4),
                if (isLink)
                  GestureDetector(
                    onTap: () {
                      // TODO: Abrir comprobante
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: small ? 12 : 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Text',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: small ? 12 : 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontFamily: small ? 'SF Pro Text' : 'SF Pro Display',
                    ),
                    maxLines: multiLine ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cardColor,
                    _cardColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Ordenar Gastos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Selecciona cómo deseas organizar tus gastos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...SortOption.values.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: _buildSortOptionItem(option),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOptionItem(SortOption option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSort = option;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(option.icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Flexible(
                  child: Text('Ordenando por ${option.label.toLowerCase()}'),
                ),
              ],
            ),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.fixed, // ✅ CORREGIDO: Cambiado de floating a fixed
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(milliseconds: 1200),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentSort == option
                ? [
                    _primaryColor.withOpacity(0.3),
                    _primaryColor.withOpacity(0.15),
                  ]
                : [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _currentSort == option
                ? _primaryColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: _currentSort == option ? _primaryColor : Colors.white.withOpacity(0.6)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: _currentSort == option ? FontWeight.w700 : FontWeight.w500,
                  color: _currentSort == option ? Colors.white : Colors.white.withOpacity(0.8),
                  fontFamily: 'SF Pro Text',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_currentSort == option)
              Icon(Icons.check_circle, color: _primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  List<ExpenseModel> _getSortedExpenses(List<ExpenseModel> expenses) {
    switch (_currentSort) {
      case SortOption.dateDesc:
        return expenses.sortedByDateDesc;
      case SortOption.dateAsc:
        return expenses.sortedByDateAsc;
      case SortOption.amountDesc:
        return expenses.sortedByAmountDesc;
      case SortOption.amountAsc:
        return expenses.sortedByAmountAsc;
      case SortOption.nameAsc:
        return expenses.sortedByNameAsc;
      case SortOption.nameDesc:
        return expenses.sortedByNameDesc;
    }
  }

  Widget _buildEnhancedNeonButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseModel expense, ExpenseProvider expenseProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cardColor,
                    _cardColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primaryColor.withOpacity(0.4),
                                _primaryColor.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _primaryColor.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(Icons.delete_forever, color: _primaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            'Confirmar Eliminación',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Esta acción eliminará permanentemente el gasto seleccionado. ¿Estás seguro de continuar?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'SF Pro Text',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  expense.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'SF Pro Display',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _accentColor.withOpacity(0.3),
                                      _accentColor.withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _accentColor.withOpacity(0.4)),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: _accentColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      shadows: [
                                        Shadow(
                                          color: _accentColor.withOpacity(0.3),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.category, size: 16, color: _primaryColor),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      expense.category.displayName,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'SF Pro Text',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.white.withOpacity(0.6)),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      expense.formattedDate,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontFamily: 'SF Pro Text',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (expense.description != null && expense.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              expense.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'SF Pro Text',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Flexible(
                          child: _buildEnhancedNeonButton(
                            text: 'Cancelar',
                            icon: Icons.close,
                            onPressed: () => Navigator.of(context).pop(),
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        Flexible(
                          child: _buildEnhancedNeonButton(
                            text: 'Eliminar',
                            icon: Icons.delete_forever,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteExpense(expense, expenseProvider);
                            },
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteExpense(ExpenseModel expense, ExpenseProvider expenseProvider) {
    expenseProvider.deleteExpense(expense.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Gasto "${expense.name}" eliminado exitosamente',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.fixed, // ✅ CORREGIDO: Cambiado de floating a fixed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Error al eliminar gasto: $error',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.fixed, // ✅ CORREGIDO: Cambiado de floating a fixed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
        ),
      );
    });
  }

  Color _getCategoryColor(ExpenseCategory category) {
    return Color(category.colorValue);
  }
}