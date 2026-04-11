import 'package:flutter/material.dart';

import '../core/ui/app_colors.dart';

class ReliabilityBadge extends StatelessWidget {
  const ReliabilityBadge({super.key, required this.score, this.size = 38});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.reliability(score);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        score.toStringAsFixed(1),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
      ),
    );
  }
}
