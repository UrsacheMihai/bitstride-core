import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

// Provide interface component for Glass App Bar.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double blur;
  final double elevation;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.blur = 0,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final fg = isDark ? Colors.white : const Color(0xFF0D1420);
    final divider = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            bottom: BorderSide(color: divider, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: NavigationToolbar(
              leading: leading ??
                  (Navigator.canPop(context)
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: fg,
                          ),
                          onPressed: () => Navigator.maybePop(context),
                        )
                      : null),
              middle: title != null
                  ? DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: fg,
                        letterSpacing: -0.4,
                      ),
                      child: title!,
                    )
                  : null,
              trailing: actions != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    )
                  : null,
              centerMiddle: centerTitle,
              middleSpacing: NavigationToolbar.kMiddleSpacing,
            ),
          ),
        ),
      ),
    );
  }
}
