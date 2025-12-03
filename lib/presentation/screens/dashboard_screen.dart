import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/expense_card.dart';
import '../widgets/dashboard_header.dart';
import 'add_expense_screen.dart';
import 'profile_screen.dart';
import 'expenses_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final Color _primaryColor = const Color(0xFFE50914);
  final Color _backgroundColor = const Color(0xFF0D0D0D);
  final Color _cardColor = const Color(0xFF1A1A1A);
  final Color _accentColor = const Color(0xFF00FF88);
  final Color _secondaryAccent = const Color(0xFF0099FF);
  final Color _goldColor = const Color(0xFFFFD700);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<ExpenseProvider>().fetchExpenses();
    // Cargar perfil para obtener avatar
    await context.read<ProfileProvider>().loadProfile();
    _animationController.forward();
  }

  Future<void> _refreshData() async {
    await context.read<ExpenseProvider>().fetchExpenses();
    await context.read<ProfileProvider>().loadProfile();
    _showRefreshSnackbar();
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
      appBar: DashboardHeader(
        animationController: _animationController,
        primaryColor: _primaryColor,
        backgroundColor: _backgroundColor,
        cardColor: _cardColor,
        accentColor: _accentColor,
        secondaryAccent: _secondaryAccent,
        goldColor: _goldColor,
        onRefresh: _refreshData,
        onShowNotifications: _showNotifications,
      ),
      body: RefreshIndicator(
        backgroundColor: _accentColor,
        color: Colors.white,
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildBody() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading && expenseProvider.expenses.isEmpty) {
          return _buildLoadingState();
        }

        if (expenseProvider.error != null) {
          return _buildErrorState(expenseProvider);
        }

        final expenses = expenseProvider.expenses.sortedByDateDesc;
        final currentMonthExpenses = expenses.currentMonthExpenses;
        final totalThisMonth = currentMonthExpenses.totalAmount;

        return Stack(
          children: [
            _buildAnimatedBackground(),
            _buildMainContent(expenses, totalThisMonth, currentMonthExpenses),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(List<ExpenseModel> expenses, double totalThisMonth, List<ExpenseModel> currentMonthExpenses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: MonthlySummary(
              totalExpenses: totalThisMonth,
              monthlyBudget: 1000.0,
              expensesByCategory: currentMonthExpenses.amountByCategory,
              primaryColor: _primaryColor,
              backgroundColor: _cardColor,
              accentColor: _accentColor,
              showGoalBadge: false,
            ),
          ),
          
          if (expenses.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildQuickStats(expenses),
            const SizedBox(height: 24),
            _buildRecentExpenses(expenses),
            const SizedBox(height: 20),
            _buildViewExpensesButton(),
          ] else 
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(List<ExpenseModel> expenses) {
    final recentExpenses = expenses.take(3).toList();
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gastos Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${recentExpenses.length} gastos',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...recentExpenses.map((expense) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseCard(
              expense: expense,
              onEdit: () => _editExpense(context, expense, context.read<ExpenseProvider>()),
              onDelete: () {
                _showDeleteDialog(context, expense, context.read<ExpenseProvider>());
              },
              primaryColor: _primaryColor,
              backgroundColor: _cardColor,
              accentColor: _accentColor,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildViewExpensesButton() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildNeonButton(
          text: 'Ver Todos los Gastos',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExpensesScreen()),
            );
          },
          color: _secondaryAccent,
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryColor.withOpacity(0.05 * _fadeAnimation.value),
                _backgroundColor,
                _accentColor.withOpacity(0.03 * _fadeAnimation.value),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPulsingIcon(Icons.account_balance_wallet, _accentColor),
          const SizedBox(height: 20),
          Text(
            'Cargando tus gastos...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ExpenseProvider expenseProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: _primaryColor),
            const SizedBox(height: 20),
            Text(
              'Error al cargar gastos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              expenseProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 24),
            _buildNeonButton(
              text: 'Reintentar',
              onPressed: () {
                expenseProvider.clearError();
                _loadData();
              },
              color: _primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<ExpenseModel> expenses) {
    final todayExpenses = expenses.todayExpenses;
    final weekExpenses = expenses.currentWeekExpenses;
    final largestExpense = expenses.largestExpense;
    final averageExpense = expenses.averageAmount;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _cardColor,
              _cardColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Hoy',
              '\$${todayExpenses.totalAmount.toStringAsFixed(0)}',
              Icons.today,
              _accentColor,
            ),
            _buildStatItem(
              'Semana',
              '\$${weekExpenses.totalAmount.toStringAsFixed(0)}',
              Icons.calendar_view_week,
              _secondaryAccent,
            ),
            _buildStatItem(
              'Mayor',
              largestExpense != null 
                  ? '\$${largestExpense.amount.toStringAsFixed(0)}'
                  : '\$0',
              Icons.arrow_upward,
              _primaryColor,
            ),
            _buildStatItem(
              'Promedio',
              '\$${averageExpense.toStringAsFixed(0)}',
              Icons.bar_chart,
              _goldColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPulsingIcon(Icons.account_balance_wallet_outlined, _accentColor),
            const SizedBox(height: 24),
            Text(
              'No hay gastos registrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza agregando tu primer gasto para controlar tus finanzas universitarias',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 32),
            _buildNeonButton(
              text: 'Agregar Primer Gasto',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              color: _accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _fadeAnimation.value,
                child: child,
              ),
            );
          },
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              ).then((_) {
                _refreshData();
              });
            },
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add, size: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeonButton({required String text, required VoidCallback onPressed, required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
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

  Widget _buildPulsingIcon(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            size: 64,
            color: color.withOpacity(value),
          ),
        );
      },
    );
  }

  void _showRefreshSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: _accentColor),
            const SizedBox(width: 8),
            const Text('Datos actualizados correctamente'),
          ],
        ),
        backgroundColor: _cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: _accentColor.withOpacity(0.3)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editExpense(BuildContext context, ExpenseModel expense, ExpenseProvider expenseProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando "${expense.name}"...'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseModel expense, ExpenseProvider expenseProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                  Icons.delete_forever,
                  size: 48,
                  color: _primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Eliminar Gasto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de que quieres eliminar este gasto?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatItemRow('Gasto:', expense.name),
                      _buildStatItemRow('Monto:', '\$${expense.amount.toStringAsFixed(2)}'),
                      _buildStatItemRow('Categoría:', expense.category.displayName),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildNeonButton(
                        text: 'Cancelar',
                        onPressed: () => Navigator.of(context).pop(),
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNeonButton(
                        text: 'Eliminar',
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
        );
      },
    );
  }

  void _deleteExpense(ExpenseModel expense, ExpenseProvider expenseProvider) {
    expenseProvider.deleteExpense(expense.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto "${expense.name}" eliminado'),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  Widget _buildStatItemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Text',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _accentColor,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODO AÑADIDO: _showNotifications - para pasar al DashboardHeader
  void _showNotifications() {
    final expenseProvider = context.read<ExpenseProvider>();
    
    // Calcular gastos de los últimos 7 días
    final recentExpenses = expenseProvider.expenses.sortedByDateDesc
        .where((expense) => expense.date.isAfter(
            DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    
    final todayExpenses = expenseProvider.expenses.todayExpenses;
    final recentExpensesCount = recentExpenses.length;
    final todayExpensesCount = todayExpenses.length;

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accentColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.notifications_active, color: _accentColor, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (todayExpensesCount > 0)
                _buildNotificationItem(
                  'Gastos de hoy',
                  '$todayExpensesCount gastos registrados hoy',
                  Icons.today,
                  _accentColor,
                ),
              if (recentExpensesCount > 0)
                _buildNotificationItem(
                  'Gastos recientes',
                  '$recentExpensesCount gastos en los últimos 7 días',
                  Icons.trending_up,
                  _secondaryAccent,
                ),
              if (todayExpensesCount == 0 && recentExpensesCount == 0)
                _buildNotificationItem(
                  'Sin notificaciones',
                  'No hay gastos recientes',
                  Icons.check_circle,
                  Colors.green,
                ),
              const SizedBox(height: 24),
              _buildNeonButton(
                text: 'Ver Todos los Gastos',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpensesScreen()),
                  );
                },
                color: _accentColor,
              ),
            ],
          ),
        );
      },
    );
  }

  // MÉTODO AÑADIDO: _buildNotificationItem - para el modal de notificaciones
  Widget _buildNotificationItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
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
}