import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/highlight.dart' show highlight;
import '../../theme/app_theme.dart';
import '../../providers/app/app_state.dart';

class EditorThemeConfig {
  final String name;
  final Color bgColor;
  final Color gutterColor;
  final Color textColor;
  final Color cursorColor;
  final Color lineNumColor;
  final Color borderColor;
  final Color headerColor;
  final Map<String, TextStyle> highlightTheme;

  const EditorThemeConfig({
    required this.name,
    required this.bgColor,
    required this.gutterColor,
    required this.textColor,
    required this.cursorColor,
    required this.lineNumColor,
    required this.borderColor,
    required this.headerColor,
    required this.highlightTheme,
  });
}

final Map<String, TextStyle> glassmorphicNeonTheme = {
  'root': const TextStyle(backgroundColor: Colors.transparent, color: Color(0xFFE6EDF3)),
  'comment': const TextStyle(color: Color(0xFF6A737D), fontStyle: FontStyle.italic),
  'quote': const TextStyle(color: Color(0xFF6A737D), fontStyle: FontStyle.italic),
  'keyword': const TextStyle(color: Color(0xFFFF007F), fontWeight: FontWeight.bold),
  'selector-tag': const TextStyle(color: Color(0xFFFF007F), fontWeight: FontWeight.bold),
  'subst': const TextStyle(color: Color(0xFFE6EDF3)),
  'number': const TextStyle(color: Color(0xFFFF9900)),
  'literal': const TextStyle(color: Color(0xFFFF9900)),
  'variable': const TextStyle(color: Color(0xFF00FFFF)),
  'template-variable': const TextStyle(color: Color(0xFF00FFFF)),
  'string': const TextStyle(color: Color(0xFF00FFFF)),
  'symbol': const TextStyle(color: Color(0xFFBD00FF)),
  'bullet': const TextStyle(color: Color(0xFFBD00FF)),
  'section': const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold),
  'title': const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold),
  'class': const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold),
  'type': const TextStyle(color: Color(0xFFBD00FF)),
  'built_in': const TextStyle(color: Color(0xFFBD00FF)),
  'meta': const TextStyle(color: Color(0xFF6A737D)),
  'deletion': const TextStyle(color: Color(0xFFFF007F)),
  'addition': const TextStyle(color: Color(0xFF39FF14)),
  'emphasis': const TextStyle(fontStyle: FontStyle.italic),
  'strong': const TextStyle(fontWeight: FontWeight.bold),
};

final Map<String, EditorThemeConfig> editorThemes = {
  'Dracula': EditorThemeConfig(
    name: 'Dracula',
    bgColor: const Color(0xFF282A36),
    gutterColor: const Color(0xFF1E1F29),
    textColor: const Color(0xFFF8F8F2),
    cursorColor: const Color(0xFFF8F8F0),
    lineNumColor: const Color(0xFF6272A4),
    borderColor: const Color(0xFF44475A),
    headerColor: const Color(0xFF191A21),
    highlightTheme: draculaTheme,
  ),
  'Monokai Sublime': EditorThemeConfig(
    name: 'Monokai Sublime',
    bgColor: const Color(0xFF272822),
    gutterColor: const Color(0xFF1E1F1C),
    textColor: const Color(0xFFF8F8F2),
    cursorColor: const Color(0xFFF8F8F0),
    lineNumColor: const Color(0xFF75715E),
    borderColor: const Color(0xFF3E3D32),
    headerColor: const Color(0xFF191919),
    highlightTheme: monokaiSublimeTheme,
  ),
  'One Dark': EditorThemeConfig(
    name: 'One Dark',
    bgColor: const Color(0xFF282C34),
    gutterColor: const Color(0xFF21252B),
    textColor: const Color(0xFFABB2BF),
    cursorColor: const Color(0xFF528BFF),
    lineNumColor: const Color(0xFF5C6370),
    borderColor: const Color(0xFF181A1F),
    headerColor: const Color(0xFF21252B),
    highlightTheme: atomOneDarkTheme,
  ),
  'GitHub Light': EditorThemeConfig(
    name: 'GitHub Light',
    bgColor: const Color(0xFFFFFFFF),
    gutterColor: const Color(0xFFF6F8FA),
    textColor: const Color(0xFF24292E),
    cursorColor: const Color(0xFF0366D6),
    lineNumColor: const Color(0xFF959DA5),
    borderColor: const Color(0xFFE1E4E8),
    headerColor: const Color(0xFFF6F8FA),
    highlightTheme: githubTheme,
  ),
  'Glassmorphic Neon': EditorThemeConfig(
    name: 'Glassmorphic Neon',
    bgColor: Colors.black.withOpacity(0.25),
    gutterColor: Colors.black.withOpacity(0.38),
    textColor: const Color(0xFFE6EDF3),
    cursorColor: const Color(0xFFFF007F),
    lineNumColor: const Color(0xFF888888),
    borderColor: Colors.white.withOpacity(0.18),
    headerColor: Colors.black.withOpacity(0.45),
    highlightTheme: glassmorphicNeonTheme,
  ),
};

// Wrap TextEditingController to apply syntax highlighting to the code field.
class CodeHighlightController extends TextEditingController {
  final String language;
  String currentThemeName;

  CodeHighlightController({
    required super.text,
    required this.language,
    required this.currentThemeName,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final themeConfig = editorThemes[currentThemeName] ?? editorThemes['Dracula']!;
    try {
      final lang = language == 'cpp' ? 'cpp' : 'python';
      final result = highlight.parse(text, language: lang);
      return TextSpan(
        style: style?.copyWith(color: themeConfig.textColor),
        children: _convertNodes(result.nodes ?? [], themeConfig.highlightTheme),
      );
    } catch (_) {
      return TextSpan(text: text, style: style);
    }
  }

  List<TextSpan> _convertNodes(
    List<dynamic> nodes,
    Map<String, TextStyle> theme,
  ) {
    List<TextSpan> spans = [];
    for (final node in nodes) {
      if (node.value != null) {
        spans.add(TextSpan(text: node.value, style: theme[node.className]));
      } else if (node.children != null) {
        spans.add(
          TextSpan(
            style: theme[node.className],
            children: _convertNodes(node.children, theme),
          ),
        );
      }
    }
    return spans;
  }
}

// Render a syntax-highlighted code editor with line numbers and language toolbar.
class CodeEditor extends StatefulWidget {
  final String initialCode;
  final String language;
  final ValueChanged<String> onChanged;

  const CodeEditor({
    super.key,
    required this.initialCode,
    required this.language,
    required this.onChanged,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

// Manage state and provide providers for Code Editor State.
class _CodeEditorState extends State<CodeEditor> {
  late CodeHighlightController _controller;
  late ScrollController _editorScroll;
  late ScrollController _lineScroll;
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = CodeHighlightController(
      text: widget.initialCode,
      language: widget.language,
      currentThemeName: 'Dracula',
    );
    _editorScroll = ScrollController();
    _lineScroll = ScrollController();
    _lineCount = _countLines(widget.initialCode);
    _controller.addListener(_handleTextChange);
    _editorScroll.addListener(() {
      if (_lineScroll.hasClients &&
          _lineScroll.offset != _editorScroll.offset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lineScroll.hasClients && _editorScroll.hasClients) {
            _lineScroll.jumpTo(_editorScroll.offset);
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context, listen: false);
    _controller.currentThemeName = appState.codeTheme;
  }

  void _handleTextChange() {
    final newCount = _countLines(_controller.text);
    if (newCount != _lineCount) {
      setState(() {
        _lineCount = newCount;
      });
    }
    widget.onChanged(_controller.text);
  }

  int _countLines(String text) {
    if (text.isEmpty) return 1;
    return '\n'.allMatches(text).length + 1;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _editorScroll.dispose();
    _lineScroll.dispose();
    super.dispose();
  }

  void _showThemePicker(BuildContext context, AppState appState) {
    final activeTheme = appState.codeTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161B22).withOpacity(0.85)
                    : Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white30 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Select Code Editor Theme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: editorThemes.keys.map((themeName) {
                        final theme = editorThemes[themeName]!;
                        final isSelected = themeName == activeTheme;
                        
                        // Pick visual accent colors for the theme circle preview
                        Color previewKeyword = const Color(0xFFFF79C6);
                        Color previewString = const Color(0xFF8BE9FD);
                        if (themeName == 'Monokai Sublime') {
                          previewKeyword = const Color(0xFFF92672);
                          previewString = const Color(0xFFA6E22E);
                        } else if (themeName == 'One Dark') {
                          previewKeyword = const Color(0xFFE06C75);
                          previewString = const Color(0xFF98C379);
                        } else if (themeName == 'GitHub Light') {
                          previewKeyword = const Color(0xFFD73A49);
                          previewString = const Color(0xFF032F62);
                        } else if (themeName == 'Glassmorphic Neon') {
                          previewKeyword = const Color(0xFFFF007F);
                          previewString = const Color(0xFF00FFFF);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? (isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.04))
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFFFF007F).withOpacity(0.3)
                                      : Colors.grey[400]!)
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            onTap: () {
                              appState.setCodeTheme(themeName);
                              Navigator.pop(context);
                            },
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.bgColor == Colors.transparent || themeName == 'Glassmorphic Neon'
                                    ? const Color(0xFF1F1F1F)
                                    : theme.bgColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.12)
                                      : Colors.black.withOpacity(0.12),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: previewKeyword,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: previewString,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(
                              themeName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: isDark
                                        ? const Color(0xFFFF007F)
                                        : AppTheme.primaryTeal,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeThemeName = appState.codeTheme;
    _controller.currentThemeName = activeThemeName;

    final themeConfig = editorThemes[activeThemeName] ?? editorThemes['Dracula']!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = themeConfig.bgColor;
    final lineNumColor = themeConfig.lineNumColor;
    final textColor = themeConfig.textColor;
    final borderColor = themeConfig.borderColor;
    final gutterColor = themeConfig.gutterColor;
    final cursorColor = themeConfig.cursorColor;
    final headerColor = themeConfig.headerColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: activeThemeName == 'Glassmorphic Neon' ? 12.0 : 0.0,
          sigmaY: activeThemeName == 'Glassmorphic Neon' ? 12.0 : 0.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: activeThemeName == 'Glassmorphic Neon'
                  ? const Color(0xFFFF007F).withOpacity(0.3)
                  : borderColor,
              width: activeThemeName == 'Glassmorphic Neon' ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: activeThemeName == 'Glassmorphic Neon'
                    ? const Color(0xFFFF007F).withOpacity(0.15)
                    : Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: activeThemeName == 'Glassmorphic Neon' ? 18 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: headerColor,
                  border: Border(
                    bottom: BorderSide(
                      color: activeThemeName == 'Glassmorphic Neon'
                          ? const Color(0xFFFF007F).withOpacity(0.2)
                          : borderColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        _Dot(color: const Color(0xFFFF5F57)),
                        const SizedBox(width: 6),
                        _Dot(color: const Color(0xFFFFBD2E)),
                        const SizedBox(width: 6),
                        _Dot(color: const Color(0xFF27C93F)),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Text(
                      widget.language == 'cpp' ? 'main.cpp' : 'main.py',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.palette_outlined, size: 18),
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      tooltip: 'Change Theme',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showThemePicker(context, appState),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (widget.language == 'cpp'
                                ? const Color(0xFF00599C)
                                : const Color(0xFF3776AB))
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.language == 'cpp' ? 'C++' : 'Python',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.language == 'cpp'
                              ? const Color(0xFF00599C)
                              : const Color(0xFF3776AB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      color: gutterColor,
                      child: SingleChildScrollView(
                        controller: _lineScroll,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 12, right: 8),
                        child: Column(
                          children: List.generate(
                            _lineCount,
                            (i) => SizedBox(
                              height: 20,
                              child: Text(
                                '${i + 1}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  color: lineNumColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      color: borderColor.withOpacity(0.5),
                    ),
                    Expanded(
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event.logicalKey == LogicalKeyboardKey.tab &&
                              event is KeyDownEvent) {
                            final text = _controller.text;
                            final selection = _controller.selection;
                            if (selection.start >= 0 && selection.end >= 0) {
                              final newText = text.replaceRange(
                                  selection.start, selection.end, '    ');
                              _controller.value = TextEditingValue(
                                text: newText,
                                selection: TextSelection.collapsed(
                                    offset: selection.start + 4),
                              );
                            }
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextField(
                          controller: _controller,
                          scrollController: _editorScroll,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: textColor,
                            height: 1.4,
                          ),
                          cursorColor: cursorColor,
                          cursorWidth: 2,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Render a small colored dot used as a language indicator.
class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
