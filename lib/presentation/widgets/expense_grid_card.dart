import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseGridCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;

  const ExpenseGridCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final bool isLargeScreen = cardWidth > 600;
        final bool isMediumScreen = cardWidth > 400 && cardWidth <= 600;
        
        // Tamaños dinámicos según la pantalla
        final double cardPadding = isLargeScreen ? 16.0 : isMediumScreen ? 14.0 : 12.0;
        final double iconSize = isLargeScreen ? 40.0 : isMediumScreen ? 36.0 : 32.0;
        final double categoryFontSize = isLargeScreen ? 11.0 : isMediumScreen ? 10.0 : 9.0;
        final double titleFontSize = isLargeScreen ? 15.0 : isMediumScreen ? 14.0 : 13.0;
        final double descriptionFontSize = isLargeScreen ? 11.0 : isMediumScreen ? 10.0 : 9.0;
        final double amountFontSize = isLargeScreen ? 20.0 : isMediumScreen ? 18.0 : 16.0;
        final double dateFontSize = isLargeScreen ? 10.0 : isMediumScreen ? 9.0 : 8.0;
        final double actionButtonSize = isLargeScreen ? 26.0 : isMediumScreen ? 24.0 : 22.0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 180,
              maxHeight: double.infinity,
            ),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Contenido principal
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Encabezado con icono y categoría
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icono de categoría
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getCategoryColor().withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  expense.category.icon,
                                  color: _getCategoryColor(),
                                  size: iconSize * 0.5,
                                ),
                              ),
                              
                              // Badge de categoría - Con ancho máximo
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: cardWidth * 0.45, // 45% del ancho máximo
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      expense.category.displayName,
                                      style: TextStyle(
                                        fontSize: categoryFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 12),
                          
                          // Nombre del gasto - Con altura máxima
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: titleFontSize * 2.6, // Máximo 2 líneas
                            ),
                            child: Text(
                              expense.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                          
                          // Descripción (si existe)
                          if (expense.description != null && expense.description!.isNotEmpty) ...[
                            SizedBox(height: 6),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: descriptionFontSize * 2.6, // Máximo 2 líneas
                              ),
                              child: Text(
                                expense.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: descriptionFontSize,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Información inferior
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Monto - Aseguramos que no se desborde
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: amountFontSize,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: 10),
                          
                          // Fecha y acciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Fecha - Flexible para ocupar el espacio disponible
                              Flexible(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _getFormattedDate(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: dateFontSize,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(width: 8),
                              
                              // Botones de acción - Fixed size
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botón de editar
                                  GestureDetector(
                                    onTap: onEdit,
                                    child: Container(
                                      width: actionButtonSize,
                                      height: actionButtonSize,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(width: 6),
                                  
                                  // Botón de eliminar
                                  GestureDetector(
                                    onTap: onDelete,
                                    child: Container(
                                      width: actionButtonSize,
                                      height: actionButtonSize,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: primaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        size: 14,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Indicador de estado (si es recurrente) - Posición absoluta
                if (expense.isRecurring)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.repeat, size: 8, color: Colors.green),
                          SizedBox(width: 2),
                          Text(
                            'Rec',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  // Métodos auxiliares
  Color _getCategoryColor() {
    return Color(expense.category.colorValue);
  }

  String _getFormattedDate() {
    return expense.shortFormattedDate;
  }
}