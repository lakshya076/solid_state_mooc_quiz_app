import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'zoomable_image.dart';

class FlashcardView extends StatelessWidget {
  final Question question;
  final int currentIndex;
  final int totalQuestions;
  final Animation<double> animation;
  final VoidCallback onFlip;
  final String? selectedOption;
  final ValueChanged<String>? onOptionSelected;
  final bool isMastered;
  final bool needsReview;
  final VoidCallback? onMarkMastered;
  final VoidCallback? onMarkNeedsReview;

  const FlashcardView({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.animation,
    required this.onFlip,
    this.selectedOption,
    this.onOptionSelected,
    this.isMastered = false,
    this.needsReview = false,
    this.onMarkMastered,
    this.onMarkNeedsReview,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double value = animation.value;
        final double angle = value * pi;
        final bool isFront = value < 0.5;

        return GestureDetector(
          onTap: onFlip,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D perspective
              ..rotateY(angle),
            child: isFront
                ? _buildFront(context)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(context),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFront(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isMastered
              ? Colors.green.shade400
              : needsReview
                  ? Colors.orange.shade400
                  : theme.dividerColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8FAFC),
                  ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Week ${question.week} • Q${question.questionNumber}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMastered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Mastered', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else if (needsReview)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay, size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Review', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('Tap to Flip', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Zoomable Question Image with pinch + buttons
            Expanded(
              child: ZoomableImage(
                imageAsset: question.imageAsset,
                heroTag: 'front_${question.id}',
              ),
            ),
            const SizedBox(height: 14),

            // Options Selector: (a), (b), (c), (d)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'Select your answer before flipping:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ),
                Row(
                  children: question.options.map((opt) {
                    final isSelected = selectedOption == opt;
                    final isCorrect = opt == question.acceptedAnswer;

                    Color btnColor;
                    Color textColor;
                    BorderSide borderSide = BorderSide.none;

                    if (selectedOption != null) {
                      if (isSelected) {
                        btnColor = isCorrect ? Colors.green.shade600 : Colors.red.shade600;
                        textColor = Colors.white;
                      } else if (isCorrect) {
                        btnColor = Colors.green.shade50;
                        textColor = Colors.green.shade800;
                        borderSide = BorderSide(color: Colors.green.shade400, width: 1.5);
                      } else {
                        btnColor = isDark ? Colors.white10 : Colors.grey.shade200;
                        textColor = isDark ? Colors.white54 : Colors.grey.shade600;
                      }
                    } else {
                      btnColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
                      textColor = isDark ? Colors.white : Colors.black87;
                      borderSide = BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300);
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Material(
                          color: btnColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: borderSide,
                          ),
                          child: InkWell(
                            onTap: () {
                              if (onOptionSelected != null) {
                                onOptionSelected!(opt);
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  '($opt)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Card Bottom Tap Cue
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flip_to_back, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Tap card to reveal answer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isCorrectGuess = selectedOption != null && selectedOption == question.acceptedAnswer;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.green, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF064E3B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFECFDF5),
                    Colors.white,
                  ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Week ${question.week} • Q${question.questionNumber} Answer',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.flip_to_front, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text('Tap to Flip Back', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Big Answer Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF065F46) : Colors.green.shade500,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ACCEPTED ANSWER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '(${question.acceptedAnswer.toUpperCase()})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  if (selectedOption != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrectGuess ? Colors.white24 : Colors.red.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCorrectGuess
                            ? '🎉 Your guess was correct!'
                            : '❌ You chose (${selectedOption!.toUpperCase()})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Question thumbnail preview with zoomable image
            Expanded(
              child: ZoomableImage(
                imageAsset: question.imageAsset,
                heroTag: 'back_${question.id}',
              ),
            ),
            const SizedBox(height: 12),

            // Self-Grading Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarkNeedsReview,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Review Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarkMastered,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mastered!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
