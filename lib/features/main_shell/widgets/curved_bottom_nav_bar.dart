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
    Icons.account_balance_wallet_rounded,
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
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
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
                      // Determine the progress of the notch moving past this item
                      final distance = (_animation.value - index).abs();
                      final yOffset = distance < 0.5 ? (1 - distance * 2) * 8 : 0.0;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onItemSelected(index),
                          child: Container(
                            height: 70, // Height of the actual bar part
                            alignment: Alignment.center,
                            child: Transform.translate(
                              offset: Offset(0, yOffset.toDouble()),
                              child: Icon(
                                _icons[index],
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.5),
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
    // Calculate exact X position for the floating dot to remain centered over the notch
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / count;
    return (itemWidth * index) + (itemWidth / 2) - 4; // 4 is half the dot width
  }
}

class _CurvedNavBarPainter extends CustomPainter {
  final double currentIndex;
  final int itemCount;

  _CurvedNavBarPainter({
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    // We want to add a subtle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final itemWidth = size.width / itemCount;
    final centerPointX = (itemWidth * currentIndex) + (itemWidth / 2);

    // Navigation bar geometry
    final curveDepth = 24.0;
    final curveWidth = itemWidth * 0.8; // How wide the notch is

    // Start drawing from top-left, but pushed down by 20px
    path.moveTo(0, 20);

    // Draw a straight line to the start of the curve
    if (centerPointX - curveWidth / 2 > 0) {
      path.lineTo(centerPointX - curveWidth / 2, 20);
    }

    // Draw the downward curve (the notch) using bezier curves
    path.cubicTo(
      centerPointX - curveWidth / 4, 20, // control point 1
      centerPointX - curveWidth / 4, 20 + curveDepth, // control point 2
      centerPointX, 20 + curveDepth, // end point (bottom of notch)
    );

    // Draw the upward curve out of the notch
    path.cubicTo(
      centerPointX + curveWidth / 4, 20 + curveDepth, // control point 1
      centerPointX + curveWidth / 4, 20, // control point 2
      centerPointX + curveWidth / 2, 20, // end point
    );

    // Draw straight line to the right edge
    path.lineTo(size.width, 20);

    // Draw down to bottom right, across to bottom left, and back up
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Draw the bar shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNavBarPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex;
  }
}
