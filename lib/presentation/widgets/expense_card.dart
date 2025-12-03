import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseCard extends StatefulWidget {
  final ExpenseModel expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onDelete,
    this.onEdit,
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.accentColor = Colors.green,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptamos el diseño según el ancho de la pantalla
        final bool isLargeScreen = constraints.maxWidth > 600;
        final double cardMargin = isLargeScreen ? 8.0 : 4.0;
        final double iconSize = isLargeScreen ? 60.0 : 50.0;
        final double fontSizeTitle = isLargeScreen ? 18.0 : 16.0;
        final double fontSizeAmount = isLargeScreen ? 22.0 : 18.0;

        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: cardMargin),
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      if (_isHovered)
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Efecto de brillo al hacer hover
                      if (_isHovered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.topLeft,
                                radius: 1.5,
                                colors: [
                                  widget.accentColor.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 0,
                          maxHeight: double.infinity,
                        ),
                        child: _buildCardContent(
                          isLargeScreen: isLargeScreen,
                          iconSize: iconSize,
                          fontSizeTitle: fontSizeTitle,
                          fontSizeAmount: fontSizeAmount,
                        ),
                      ),
                      
                      // Badge de recurrencia
                      if (widget.expense.isRecurring)
                        Positioned(
                          top: isLargeScreen ? 12 : 8,
                          right: isLargeScreen ? 12 : 8,
                          child: _buildRecurrenceBadge(isLargeScreen: isLargeScreen),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCardContent({
    required bool isLargeScreen,
    required double iconSize,
    required double fontSizeTitle,
    required double fontSizeAmount,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : 16,
        vertical: isLargeScreen ? 16 : 12,
      ),
      leading: _buildCategoryIcon(
        iconSize: iconSize,
        isLargeScreen: isLargeScreen,
      ),
      title: _buildTitle(
        isLargeScreen: isLargeScreen,
        fontSizeTitle: fontSizeTitle,
      ),
      subtitle: _buildSubtitle(isLargeScreen: isLargeScreen),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 120 : 100,
        ),
        child: _buildAmountSection(
          isLargeScreen: isLargeScreen,
          fontSizeAmount: fontSizeAmount,
        ),
      ),
      onTap: () => _showOptions(context),
      minVerticalPadding: 8,
    );
  }

  Widget _buildCategoryIcon({
    required double iconSize,
    required bool isLargeScreen,
  }) {
    return Container(
      width: iconSize,
      height: iconSize,
      constraints: BoxConstraints(
        maxWidth: iconSize,
        maxHeight: iconSize,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(widget.expense.category.colorValue).withOpacity(0.9),
            Color(widget.expense.category.colorValue).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(widget.expense.category.colorValue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          widget.expense.category.emoji,
          style: TextStyle(fontSize: isLargeScreen ? 24 : 20),
        ),
      ),
    );
  }

  Widget _buildTitle({
    required bool isLargeScreen,
    required double fontSizeTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.expense.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: fontSizeTitle,
            color: Colors.white,
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: isLargeScreen ? 8 : 6,
          runSpacing: 4,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 10 : 8,
                vertical: isLargeScreen ? 4 : 2,
              ),
              decoration: BoxDecoration(
                color: Color(widget.expense.category.colorValue).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Color(widget.expense.category.colorValue).withOpacity(0.4),
                ),
              ),
              child: Text(
                widget.expense.category.displayName,
                style: TextStyle(
                  fontSize: isLargeScreen ? 12 : 10,
                  color: Color(widget.expense.category.colorValue),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
            if (widget.expense.isRecent)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 8 : 6,
                  vertical: isLargeScreen ? 3 : 2,
                ),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: widget.accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  'NUEVO',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 9 : 8,
                    color: widget.accentColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtitle({required bool isLargeScreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.expense.description != null && widget.expense.description!.isNotEmpty) ...[
          SizedBox(height: isLargeScreen ? 6 : 4),
          Text(
            widget.expense.description!,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Text',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: isLargeScreen ? 8 : 6),
        Wrap(
          spacing: isLargeScreen ? 8 : 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: isLargeScreen ? 14 : 12,
              color: Colors.white.withOpacity(0.5),
            ),
            Text(
              _formatDate(widget.expense.date),
              style: TextStyle(
                fontSize: isLargeScreen ? 12 : 11,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Pro Text',
              ),
            ),
            if (widget.expense.isRecurring && widget.expense.recurrenceDisplayName != null) ...[
              Icon(
                widget.expense.recurrenceIcon,
                size: isLargeScreen ? 14 : 12,
                color: widget.primaryColor.withOpacity(0.7),
              ),
              Text(
                widget.expense.recurrenceDisplayName!,
                style: TextStyle(
                  fontSize: isLargeScreen ? 12 : 11,
                  color: widget.primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSection({
    required bool isLargeScreen,
    required double fontSizeAmount,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '\$${widget.expense.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSizeAmount,
              fontWeight: FontWeight.w800,
              color: widget.accentColor,
              fontFamily: 'SF Pro Display',
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: widget.accentColor.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isLargeScreen ? 6 : 4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 10 : 8,
            vertical: isLargeScreen ? 4 : 3,
          ),
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 120 : 100,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            _getTimeAgo(widget.expense.date),
            style: TextStyle(
              fontSize: isLargeScreen ? 10 : 9,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Text',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecurrenceBadge({required bool isLargeScreen}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 8 : 6,
        vertical: isLargeScreen ? 4 : 3,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primaryColor.withOpacity(0.9),
            widget.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 10 : 8),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            size: isLargeScreen ? 10 : 8,
            color: Colors.white,
          ),
          SizedBox(width: isLargeScreen ? 4 : 3),
          Text(
            'REC',
            style: TextStyle(
              fontSize: isLargeScreen ? 8 : 7,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDay = DateTime(date.year, date.month, date.day);

    if (expenseDay == today) {
      return 'Hoy';
    } else if (expenseDay == yesterday) {
      return 'Ayer';
    } else {
      final difference = now.difference(date);
      if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace ${weeks}w';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Hace ${months}m';
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.35,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
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
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(widget.expense.category.colorValue)
                                    .withOpacity(0.8),
                                Color(widget.expense.category.colorValue)
                                    .withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              widget.expense.category.emoji,
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
                                widget.expense.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${widget.expense.amount.toStringAsFixed(2)} • ${widget.expense.category.displayName}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOptionItem(
                    icon: Icons.edit,
                    title: 'Editar gasto',
                    subtitle: 'Modificar información del gasto',
                    color: widget.accentColor,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToEditScreen();
                    },
                  ),
                  _buildOptionItem(
                    icon: Icons.delete,
                    title: 'Eliminar gasto',
                    subtitle: 'Eliminar permanentemente',
                    color: widget.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDelete?.call();
                    },
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
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  void _navigateToEditScreen() {
    if (widget.onEdit != null) {
      widget.onEdit!();
    } else {
      Navigator.pushNamed(
        context,
        '/editExpense',
        arguments: widget.expense,
      );
    }
  }
}