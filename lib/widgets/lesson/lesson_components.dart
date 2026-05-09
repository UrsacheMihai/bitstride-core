import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/exercise/exercise.dart';
import '../../theme/app_theme.dart';
import '../common/page_transitions.dart';
import '../../screens/visualizer/algorithm_visualizer_screen.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

// Render the lesson content with theory, code blocks, and quiz tabs.
class LearnTab extends StatelessWidget {
  final List<ContentBlock> blocks;
  final bool isDark;
  // Support both single and multi-choice: maps block index to list of selected option indices.
  final Map<int, List<int>> selectedOptions;
  final Function(int blockIndex, int optionIndex)? onOptionSelected;

  const LearnTab({
    super.key,
    required this.blocks,
    required this.isDark,
    this.selectedOptions = const {},
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: blocks.length,
      itemBuilder: (ctx, i) => _renderBlock(context, blocks[i], i),
    );
  }

  Widget _renderBlock(BuildContext context, ContentBlock block, int index) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            block.content,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        );
      case 'code':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            ),
          ),
          child: Text(
            block.content,
            style: const TextStyle(
                fontFamily: 'monospace', fontSize: 13, height: 1.6),
          ),
        );
      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              block.content,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.grey, size: 40),
                ),
              ),
            ),
          ),
        );
      case 'quiz':
        final quiz = QuizData.parse(block.content);
        if (quiz == null) return const SizedBox.shrink();
        // Pass selected indices list for this block.
        return QuizBlockWidget(
          quiz: quiz,
          selectedIndices: selectedOptions[index] ?? [],
          onOptionSelected: (optIndex) {
            if (onOptionSelected != null) {
              onOptionSelected!(index, optIndex);
            }
          },
          isDark: isDark,
        );
      case 'visualizer':
        return const SizedBox.shrink();
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: MarkdownBody(
            data: block.content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 15, height: 1.7),
              strong: const TextStyle(
                  fontSize: 15, height: 1.7, fontWeight: FontWeight.w700),
              em: const TextStyle(
                  fontSize: 15, height: 1.7, fontStyle: FontStyle.italic),
              code: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                backgroundColor:
                    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
              ),
              codeblockDecoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
              a: TextStyle(
                color: AppTheme.primaryCyan,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.primaryCyan.withOpacity(0.4),
              ),
              listBullet: const TextStyle(fontSize: 15, height: 1.7),
            ),
            onTapLink: (text, href, title) {
              if (href == null) return;
              if (href.startsWith('algo:')) {
                final algoId = href.substring(5);
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page:
                        AlgorithmVisualizerScreen(preselectedAlgorithm: algoId),
                  ),
                );
              } else {
                launchUrl(Uri.parse(href),
                  mode: LaunchMode.externalApplication);
              }
            },
          ),
        );
    }
  }
}

// Render individual quiz choice option with radio (single) or checkbox (multiple) indicator.
class QuizOptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMultipleChoice;
  final VoidCallback onTap;
  final bool isDark;

  const QuizOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    this.isMultipleChoice = false,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.08)
                : (isDark ? AppTheme.darkCard2 : Colors.grey.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Render checkbox for multi-choice or radio circle for single-choice.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  // Draw a square shape for a checkbox and a circle for a radio button.
                  borderRadius: isMultipleChoice
                      ? BorderRadius.circular(4)
                      : BorderRadius.circular(10),
                  color: isSelected ? activeColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? activeColor : Colors.grey,
                    width: 2,
                  ),
                ),
                // Show checkmark icon when selected in multiple-choice mode.
                child: isSelected && isMultipleChoice
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : (isSelected && !isMultipleChoice
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeColor,
                              ),
                            ),
                          )
                        : null),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.grey[300] : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create quiz widget for presenting interactive questions with single or multiple choice.
class QuizBlockWidget extends StatelessWidget {
  final QuizData quiz;
  // Store the list of currently selected option indices.
  final List<int> selectedIndices;
  final Function(int) onOptionSelected;
  final bool isDark;

  const QuizBlockWidget({
    super.key,
    required this.quiz,
    required this.selectedIndices,
    required this.onOptionSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    bool isIncorrect = false;
    if (selectedIndices.isNotEmpty) {
      if (!quiz.isMultipleChoice) {
        isIncorrect = selectedIndices.first != quiz.correctIndex;
      } else {
        final hasWrongSelection = selectedIndices.any((idx) => !quiz.correctIndices.contains(idx));
        final reachedMaxCorrect = selectedIndices.length >= quiz.correctIndices.length;
        final exactMatch = selectedIndices.length == quiz.correctIndices.length &&
            selectedIndices.every((idx) => quiz.correctIndices.contains(idx));
        isIncorrect = hasWrongSelection || (reachedMaxCorrect && !exactMatch);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: AppTheme.accentPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              // Render quiz type label (single or multiple choice).
              Text(
                quiz.isMultipleChoice ? l.multipleChoice : l.quizQuestion,
                style: const TextStyle(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            quiz.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          // Render option cards with correct mode based on isMultipleChoice flag.
          ...List.generate(quiz.options.length, (index) {
            return QuizOptionCard(
              text: quiz.options[index],
              isSelected: selectedIndices.contains(index),
              isMultipleChoice: quiz.isMultipleChoice,
              onTap: () => onOptionSelected(index),
              isDark: isDark,
            );
          }),
          if (isIncorrect) ...[
            Builder(
              builder: (context) {
                String displayExplanation = '';
                if (selectedIndices.isNotEmpty) {
                  final List<int> incorrectSelections = selectedIndices
                      .where((idx) => quiz.isMultipleChoice
                          ? !quiz.correctIndices.contains(idx)
                          : idx != quiz.correctIndex)
                      .toList();

                  final List<String> optionExps = [];
                  for (final idx in incorrectSelections) {
                    if (quiz.explanations.length > idx && quiz.explanations[idx].isNotEmpty) {
                      optionExps.add(quiz.explanations[idx]);
                    }
                  }

                  if (optionExps.isNotEmpty) {
                    displayExplanation = optionExps.join('\n\n');
                  } else if (quiz.explanation.isNotEmpty) {
                    displayExplanation = quiz.explanation;
                  } else {
                    displayExplanation = 'Incorrect answer. Try again!';
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.amber.withOpacity(0.15), Colors.orange.withOpacity(0.05)]
                          : [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.amber.withOpacity(isDark ? 0.3 : 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(isDark ? 0.05 : 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.quizExplanation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.amber,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayExplanation,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                color: isDark ? Colors.grey[200] : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ],
        ],
      ),
    );
  }
}

// Render a styled code example block with syntax highlighting.
class ExampleBlock extends StatelessWidget {
  final String label;
  final String value;

  const ExampleBlock({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: Text(
              value.isEmpty ? '(empty)' : value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

// Render a selectable language tab pill for C++ or Python.
class LanguageTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  const LanguageTab({
    super.key,
    required this.title,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

// Provide interface component for Constraint Chip.
class ConstraintChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const ConstraintChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Provide interface component for Lesson Type Badge.
class LessonTypeBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const LessonTypeBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
