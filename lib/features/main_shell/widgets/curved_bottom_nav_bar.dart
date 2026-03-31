import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';

class CurvedBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CurvedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CurvedBottomNavBar> createState() => _CurvedBottomNavBarState();
}

class _CurvedBottomNavBarState extends State<CurvedBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousIndex = 0;

  final List<IconData> _icons = [
    Icons.space_dashboard_rounded,
    Icons.auto_awesome_rounded,
    Icons.menu_book_rounded,
    Icons.emoji_events_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(covariant CurvedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _animation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.selectedIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      color: Colors.transparent,
      height: 90,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CurvedNavBarPainter(
              currentIndex: _animation.value,
              itemCount: _icons.length,
              barColor: c.surface,
              isDark: context.isDarkMode,
            ),
            child: SizedBox(
              height: 90,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 12,
                    left: _getDotPosition(
                      context,
                      _animation.value,
                      _icons.length,
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Navigation Items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_icons.length, (index) {
                      final isSelected = widget.selectedIndex == index;
                      final distance = (_animation.value - index).abs();
                      final yOffset = distance < 0.5 ? (1 - distance * 2) * 8 : 0.0;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onItemSelected(index),
                          child: Container(
                            height: 70,
                            alignment: Alignment.center,
                            child: Transform.translate(
                              offset: Offset(0, yOffset.toDouble()),
                              child: Icon(
                                _icons[index],
                                color: isSelected
                                    ? c.primary
                                    : c.textSecondary.withValues(alpha: 0.5),
                                size: isSelected ? 28 : 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getDotPosition(BuildContext context, double index, int count) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / count;
    return (itemWidth * index) + (itemWidth / 2) - 4;
  }
}

class _CurvedNavBarPainter extends CustomPainter {
  final double currentIndex;
  final int itemCount;
  final Color barColor;
  final bool isDark;

  _CurvedNavBarPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.barColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final itemWidth = size.width / itemCount;
    final centerPointX = (itemWidth * currentIndex) + (itemWidth / 2);

    final curveDepth = 24.0;
    final curveWidth = itemWidth * 0.8;

    path.moveTo(0, 20);

    if (centerPointX - curveWidth / 2 > 0) {
      path.lineTo(centerPointX - curveWidth / 2, 20);
    }

    path.cubicTo(
      centerPointX - curveWidth / 4, 20,
      centerPointX - curveWidth / 4, 20 + curveDepth,
      centerPointX, 20 + curveDepth,
    );

    path.cubicTo(
      centerPointX + curveWidth / 4, 20 + curveDepth,
      centerPointX + curveWidth / 4, 20,
      centerPointX + curveWidth / 2, 20,
    );

    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNavBarPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.barColor != barColor;
  }
}
