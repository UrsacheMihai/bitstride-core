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
}