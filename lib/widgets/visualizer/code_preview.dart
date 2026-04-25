import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Display syntax-highlighted code for the selected algorithm.
class CodePreview extends StatefulWidget {
  final String algorithmId;
  final int highlightLine;
  final bool isDark;

  const CodePreview({
    super.key,
    required this.algorithmId,
    this.highlightLine = -1,
    required this.isDark,
  });

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

// Manage state and provide providers for Code Preview State.
class _CodePreviewState extends State<CodePreview> {
  bool _showCpp = true;

  @override
  Widget build(BuildContext context) {
    final code = _showCpp
        ? _cppCode[widget.algorithmId] ?? ''
        : _pyCode[widget.algorithmId] ?? '';
    final lines = code.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Icon(Icons.code_rounded,
                  size: 14,
                  color: widget.isDark ? Colors.grey[500] : Colors.grey[600]),
              const SizedBox(width: 6),
              Text('Source Code',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark ? Colors.grey[500] : Colors.grey[600],
                  )),
              const Spacer(),
              _LangToggle(
                label: 'C++',
                active: _showCpp,
                isDark: widget.isDark,
                onTap: () => setState(() => _showCpp = true),
              ),
              const SizedBox(width: 4),
              _LangToggle(
                label: 'Python',
                active: !_showCpp,
                isDark: widget.isDark,
                onTap: () => setState(() => _showCpp = false),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            itemCount: lines.length,
            itemBuilder: (_, i) {
              final isHighlighted = i == widget.highlightLine;
              return Container(
                color: isHighlighted
                    ? AppTheme.primaryCyan
                        .withOpacity(widget.isDark ? 0.15 : 0.12)
                    : Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isHighlighted
                              ? AppTheme.primaryCyan
                              : (widget.isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isHighlighted)
                      Container(
                        width: 3,
                        height: 16,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    Expanded(
                      child: _buildCodeLine(
                          lines[i], widget.isDark, isHighlighted),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeLine(String line, bool isDark, bool highlighted) {
    final spans = <TextSpan>[];
    final keywords = _showCpp
        ? {
            'void',
            'int',
            'for',
            'while',
            'if',
            'else',
            'return',
            'bool',
            'true',
            'false',
            'auto',
            'const',
            'swap',
            'vector',
            'size_t',
            'break'
          }
        : {
            'def',
            'for',
            'while',
            'if',
            'else',
            'return',
            'in',
            'range',
            'len',
            'True',
            'False',
            'not',
            'and',
            'or',
            'break'
          };
    final commentPrefix = _showCpp ? '//' : '#';
    final baseColor = isDark ? Colors.grey[300]! : Colors.grey[800]!;
    final commentIdx = line.indexOf(commentPrefix);
    if (commentIdx == 0) {
      return Text(line,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            height: 1.5,
            color: isDark ? Colors.grey[600] : Colors.grey[500],
            fontStyle: FontStyle.italic,
          ));
    }
    final words = line.split(RegExp(
        r'(?<=\s)|(?=\s)|(?<=[(){}\[\],;:<>!=+\-*/])|(?=[(){}\[\],;:<>!=+\-*/])'));
    for (final word in words) {
      Color color = baseColor;
      FontWeight weight = FontWeight.w400;
      if (keywords.contains(word.trim())) {
        color = const Color(0xFFC678DD);
        weight = FontWeight.w600;
      } else if (RegExp(r'^\d+$').hasMatch(word.trim())) {
        color = const Color(0xFFD19A66);
      } else if (word.contains('"') || word.contains("'")) {
        color = const Color(0xFF98C379);
      } else if ({'(', ')', '{', '}', '[', ']', ';', ','}
          .contains(word.trim())) {
        color = isDark ? Colors.grey[600]! : Colors.grey[500]!;
      }
      spans.add(TextSpan(
        text: word,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          height: 1.5,
          color: color,
          fontWeight: weight,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// Toggle the displayed language between C++ and Python.
class _LangToggle extends StatelessWidget {
}