import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class MonthlySummary extends StatefulWidget {
  final double totalExpenses;
  final double monthlyBudget;
  final Map<ExpenseCategory, double> expensesByCategory;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final bool showGoalBadge;

  const MonthlySummary({
    super.key,
    required this.totalExpenses,
    required this.monthlyBudget,
    required this.expensesByCategory,
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.accentColor = Colors.green,
    this.showGoalBadge = true,
  });

  @override
  State<MonthlySummary> createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  double get remainingBudget => widget.monthlyBudget - widget.totalExpenses;
  double get progress => widget.monthlyBudget > 0 ? widget.totalExpenses / widget.monthlyBudget : 0;
  bool get isOverBudget => widget.totalExpenses > widget.monthlyBudget;
  bool get isNearBudget => progress >= 0.8 && !isOverBudget;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress > 1 ? 1.0 : progress,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(MonthlySummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalExpenses != widget.totalExpenses || 
        oldWidget.monthlyBudget != widget.monthlyBudget) {
      if (_animationController.isCompleted) {
        _animationController.reset();
      }
      if (mounted) {
        _animationController.forward();
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
    if (!mounted) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: double.infinity,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.backgroundColor.withOpacity(0.9),
                    widget.backgroundColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: (isOverBudget ? widget.primaryColor : widget.accentColor).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildProgressBar(),
                  const SizedBox(height: 12),
                  _buildProgressInfo(),
                  const SizedBox(height: 20),
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  if (widget.expensesByCategory.isNotEmpty) 
                    _buildTopCategories(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resumen Mensual',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.5,
          ),
        ),
        if (widget.showGoalBadge) _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'SF Pro Text',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 16,
                  width: availableWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 16,
                      width: availableWidth * _progressAnimation.value,
                      decoration: BoxDecoration(
                        gradient: _getProgressGradient(),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (!isOverBudget) 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProgressMark(0.33, availableWidth),
                      _buildProgressMark(0.66, availableWidth),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressMark(double position, double totalWidth) {
    return Container(
      width: totalWidth * 0.33,
      height: 16,
      child: Center(
        child: Container(
          width: 2,
          height: 16,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildProgressInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${(progress * 100).toStringAsFixed(1)}% del presupuesto',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Text',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _getBudgetStatusMessage(),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(),
              fontWeight: FontWeight.w700,
              fontFamily: 'SF Pro Text',
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: _buildSummaryCard(
              'Gastado',
              widget.totalExpenses,
              isOverBudget ? widget.primaryColor : widget.accentColor,
              Icons.trending_up,
            ),
          ),
          _buildVerticalDivider(),
          Flexible(
            child: _buildSummaryCard(
              'Presupuesto',
              widget.monthlyBudget,
              Colors.white,
              Icons.account_balance_wallet,
            ),
          ),
          _buildVerticalDivider(),
          Flexible(
            child: _buildSummaryCard(
              isOverBudget ? 'Excedido' : 'Restante',
              remainingBudget.abs(),
              isOverBudget ? widget.primaryColor : Colors.white.withOpacity(0.8),
              isOverBudget ? Icons.warning : Icons.savings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Text',
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'SF Pro Display',
              letterSpacing: -0.5,
              shadows: [
                if (color == widget.accentColor || color == widget.primaryColor)
                  Shadow(
                    blurRadius: 10,
                    color: color.withOpacity(0.3),
                  ),
              ],
            ),
          ),
        ),
        if (amount == widget.totalExpenses && widget.monthlyBudget > 0) ...[
          const SizedBox(height: 2),
          Text(
            '${(amount / widget.monthlyBudget * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildTopCategories() {
    final sortedCategories = widget.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedCategories.take(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Top Categorías',
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
            const SizedBox(width: 8),
            Text(
              '${widget.expensesByCategory.length} categorías',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topCategories.map((entry) => _buildCategoryItem(entry)),
        
        if (widget.expensesByCategory.length > 3) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showAllCategories,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver todas las categorías',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: widget.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryItem(MapEntry<ExpenseCategory, double> entry) {
    final percentage = widget.totalExpenses > 0 ? (entry.value / widget.totalExpenses) * 100 : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(entry.key.colorValue).withOpacity(0.8),
                  Color(entry.key.colorValue).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(entry.key.colorValue).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                entry.key.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'SF Pro Text',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${percentage.toStringAsFixed(1)}% del total',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
              Text(
                '${(entry.value / widget.monthlyBudget * 100).toStringAsFixed(1)}% presup.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isOverBudget) return widget.primaryColor;
    if (isNearBudget) return const Color(0xFFFFA500);
    return widget.accentColor;
  }

  Gradient _getStatusGradient() {
    final color = _getStatusColor();
    return LinearGradient(
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.6),
      ],
    );
  }

  Gradient _getProgressGradient() {
    if (isOverBudget) {
      return LinearGradient(
        colors: [
          widget.primaryColor,
          const Color(0xFFFF6B6B),
        ],
      );
    } else if (isNearBudget) {
      return LinearGradient(
        colors: [
          const Color(0xFFFFA500),
          const Color(0xFFFFD700),
        ],
      );
    } else {
      return LinearGradient(
        colors: [
          widget.accentColor,
          const Color(0xFF00CC88),
        ],
      );
    }
  }

  IconData _getStatusIcon() {
    if (isOverBudget) return Icons.warning;
    if (isNearBudget) return Icons.notifications;
    return Icons.check_circle;
  }

  String _getStatusText() {
    if (isOverBudget) return 'EXCEDIDO';
    if (isNearBudget) return 'ATENCIÓN';
    return 'EN META';
  }

  String _getBudgetStatusMessage() {
    if (isOverBudget) {
      return 'Excedido por \$${remainingBudget.abs().toStringAsFixed(2)}';
    } else if (isNearBudget) {
      return 'Cerca del límite';
    } else {
      return 'Dentro del presupuesto';
    }
  }

  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true, // ✅ CORREGIDO: Añadir esto
      builder: (context) {
        return DraggableScrollableSheet( // ✅ CORREGIDO: Usar DraggableScrollableSheet
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Todas las Categorías',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded( // ✅ CORREGIDO: Ahora sí puede usar Expanded
                    child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: widget.expensesByCategory.length,
                      itemBuilder: (context, index) {
                        final entry = widget.expensesByCategory.entries.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: _buildCategoryItem(entry),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.7),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, size: 16),
                          SizedBox(width: 8),
                          Text('Cerrar'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }
}