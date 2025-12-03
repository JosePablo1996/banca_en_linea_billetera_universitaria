import 'package:flutter/material.dart';

class SettingsOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;
  final Color backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool hasDivider;

  const SettingsOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.trailing,
    this.showChevron = false,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.titleColor,
    this.subtitleColor,
    this.hasDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          iconColor.withOpacity(0.2),
                          iconColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: titleColor ?? Colors.white,
                            fontFamily: 'SF Pro Display',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor ?? Colors.white.withOpacity(0.6),
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  if (trailing != null) 
                    trailing!
                  else if (showChevron)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
        
        if (hasDivider)
          Padding(
            padding: const EdgeInsets.only(left: 76, right: 16),
            child: Divider(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}