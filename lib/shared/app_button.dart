
import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class AppButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color labelColor;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.labelColor,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDots(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int activeDot = (_animation.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedOpacity(
                opacity: i <= activeDot ? 1 : 0.2,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '.',
                  style: TextStyle(
                    color: color,
                    fontSize: Responsive(context).body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        disabledBackgroundColor: widget.backgroundColor,
        textStyle: TextStyle(
          fontSize: responsive.body,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: widget.isLoading ? null : widget.onTap,
      child: widget.isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Loading',
                  style: TextStyle(
                    color: widget.labelColor,
                    fontSize: responsive.body,
                    fontFamily: "Poppins"
                  ),
                ),
                _buildAnimatedDots(widget.labelColor),
              ],
            )
          : Text(
              widget.title,
              style: TextStyle(
                color: widget.labelColor,
                fontSize: responsive.body,
                fontFamily: "Poppins"
              ),
            ),
    );
  }
}
