import 'package:flutter/material.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

/// Premium empty state widget with animations and gaming-inspired design
class EmptyStateWidget extends StatefulWidget {
  const EmptyStateWidget({super.key});

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _bellController;
  late AnimationController _fadeController;
  late Animation<double> _bellAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Bell swing animation
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bellAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.elasticInOut),
    );
    _bellController.repeat(reverse: true);

    // Fade and slide animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _bellController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColor.emptyStateGradient),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIllustration(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildSubtitle(),
                  const SizedBox(height: 32),
                  _buildHintCards(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background glow effect
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColor.primary.withValues(alpha: 0.15),
                AppColor.primary.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Animated bell icon
        AnimatedBuilder(
          animation: _bellAnimation,
          builder: (context, child) {
            return Transform.rotate(angle: _bellAnimation.value, child: child);
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryLight.withValues(alpha: 0.3),
                  AppColor.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColor.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
        // Decorative dots
        Positioned(
          top: 20,
          right: 30,
          child: _buildDot(8, AppColor.neonPink.withValues(alpha: 0.6)),
        ),
        Positioned(
          bottom: 30,
          left: 25,
          child: _buildDot(6, AppColor.neonBlue.withValues(alpha: 0.6)),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: _buildDot(4, AppColor.secondary.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildTitle() {
    return Text(
      'No Reminders Yet',
      style: AppTypography.headlineSmall.copyWith(
        color: AppColor.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Stay on top of your tasks!\nTap the + button to create your first reminder.',
      style: AppTypography.bodyMedium.copyWith(
        color: AppColor.textSecondary,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildHintCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFeatureChip(Icons.schedule_rounded, 'Set Time'),
        const SizedBox(width: 12),
        _buildFeatureChip(Icons.priority_high_rounded, 'Priority'),
        const SizedBox(width: 12),
        _buildFeatureChip(Icons.repeat_rounded, 'Repeat'),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
