import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/font_manager.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/styles_manager.dart';
import '../constants/assets.dart';
import '../extensions/extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.showBackButton = true,
    this.onBackPressed,
    this.useGradient = false,
    this.gradientColors,
    this.showShadow = false,
    this.backIcon,
    this.titleFontSize,
    this.subtitle,
    this.subtitleColor,
    this.systemOverlayStyle,
    this.primary = true,
    this.useSubtitleBadge = false,
    this.subtitleIcon,
  });

  /// Factory constructor for simple app bar without shadow or gradients.
  factory CustomAppBar.simple({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      showShadow: false,
    );
  }

  /// Factory constructor for app bar with subtitle.
  factory CustomAppBar.withSubtitle({
    String? title,
    Widget? titleWidget,
    required String subtitle,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    bool useSubtitleBadge = false,
    IconData? subtitleIcon,
  }) {
    return CustomAppBar(
      title: title,
      titleWidget: titleWidget,
      subtitle: subtitle,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      useSubtitleBadge: useSubtitleBadge,
      subtitleIcon: subtitleIcon,
    );
  }

  /// Factory constructor with logo in the center and optional title/subtitle.
  factory CustomAppBar.logo({
    Widget? logo,
    String? title,
    String? subtitle,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    Widget? leading,
    Color? backgroundColor,
    bool useSubtitleBadge = false,
    IconData? subtitleIcon,
  }) {
    return CustomAppBar(
      titleWidget:
          logo ??
          Image.asset(
            AppAssets.authHeaderLogo,
            height: 29,
            fit: BoxFit.contain,
          ),
      title: title,
      subtitle: subtitle,
      actions: actions,
      leading: leading,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      backgroundColor: backgroundColor,
      useSubtitleBadge: useSubtitleBadge,
      subtitleIcon: subtitleIcon,
    );
  }

  /// Factory constructor with gradient background.
  factory CustomAppBar.gradient({
    required String title,
    String? subtitle,
    List<Color>? gradientColors,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      useGradient: true,
      gradientColors: gradientColors,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
    );
  }

  /// Factory constructor with transparent background and zero elevation.
  factory CustomAppBar.transparent({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    Color? titleColor,
  }) {
    return CustomAppBar(
      title: title,
      elevation: 0,
      showShadow: false,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      titleColor: titleColor,
    );
  }

  /// Factory constructor with a search button in actions.
  factory CustomAppBar.search({
    required String title,
    VoidCallback? onSearchPressed,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      title: title,
      showBackButton: showBackButton,
      actions: [
        Builder(
          builder: (context) {
            final color = context.colorScheme;
            return Container(
              margin: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: color.primary,
                ),
                onPressed: onSearchPressed,
              ),
            );
          },
        ),
      ],
      onBackPressed: onBackPressed,
    );
  }

  /// Factory constructor for modern style app bar.
  factory CustomAppBar.modern({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      backgroundColor: backgroundColor,
      showShadow: false,
      titleFontSize: FontSize.size18,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      backIcon: Icons.arrow_back_ios_new_rounded,
    );
  }

  /// Factory constructor for premium gradient app bar.
  factory CustomAppBar.premium({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      useGradient: true,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
    );
  }

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool useGradient;
  final List<Color>? gradientColors;
  final bool showShadow;
  final IconData? backIcon;
  final double? titleFontSize;
  final String? subtitle;
  final Color? subtitleColor;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool primary;
  final bool useSubtitleBadge;
  final IconData? subtitleIcon;

  bool get _hasLogoWithTitle => titleWidget != null && title != null;

  double get _effectiveToolbarHeight {
    if (subtitle != null && titleWidget == null) {
      return 70.0;
    }
    return kToolbarHeight;
  }

  double get _effectiveBottomHeight {
    if (bottom != null) {
      return bottom!.preferredSize.height;
    }
    if (_hasLogoWithTitle) {
      return subtitle != null ? 50.0 : 30.0;
    }
    return 0.0;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(_effectiveToolbarHeight + _effectiveBottomHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final canPop = Navigator.of(context).canPop();

    final effectiveGradientColors =
        gradientColors ??
        [
          color.primary.withValues(alpha: 0.12),
          color.primary.withValues(alpha: 0.03),
        ];

    PreferredSizeWidget? effectiveBottom = bottom;
    if (bottom == null && _hasLogoWithTitle) {
      effectiveBottom = PreferredSize(
        preferredSize: Size.fromHeight(subtitle != null ? 50.0 : 30.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title!,
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: titleFontSize ?? FontSize.size16,
                  color: titleColor ?? color.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: Spacing.border),
                _buildSubtitleWidget(context, color),
              ],
            ],
          ),
        ),
      );
    }

    final content = Container(
      decoration: useGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: effectiveGradientColors,
              ),
            )
          : null,
      child: AppBar(
        primary: primary,
        systemOverlayStyle:
            systemOverlayStyle ??
            SystemUiOverlayStyle(
              statusBarColor: color.surface.withValues(alpha: 0),
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness:
                  Theme.of(context).brightness == Brightness.dark
                  ? Brightness.dark
                  : Brightness.light,
            ),
        automaticallyImplyLeading: false,
        leading: _buildLeading(context, canPop),
        title: _hasLogoWithTitle ? titleWidget : _buildTitle(context),
        centerTitle: centerTitle,
        actions: _buildActions(context),
        backgroundColor: backgroundColor ?? color.surface.withValues(alpha: 0),
        elevation: elevation ?? (showShadow ? 1 : 0),
        scrolledUnderElevation: 0,
        shadowColor: showShadow ? color.shadow.withValues(alpha: 0.1) : null,
        surfaceTintColor: color.surface.withValues(alpha: 0),
        bottom: effectiveBottom,
        titleSpacing: leading != null ? 0 : null,
        toolbarHeight: _effectiveToolbarHeight,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          final topPadding = primary ? MediaQuery.paddingOf(context).top : 0.0;
          return SizedBox(
            height: preferredSize.height + topPadding,
            child: content,
          );
        }
        return content;
      },
    );
  }

  Widget? _buildLeading(BuildContext context, bool canPop) {
    if (leading != null) {
      return Center(child: leading);
    }

    if (!showBackButton) return null;

    if (onBackPressed == null && (!automaticallyImplyLeading || !canPop)) {
      return null;
    }

    return IconButton(
      icon: Icon(backIcon ?? Icons.arrow_back_ios_new_rounded),
      onPressed: onBackPressed ?? () => context.maybePopRoute(),
      splashRadius: 20,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget == null && title == null) return null;

    final color = context.colorScheme;
    final List<Widget> children = [];

    if (titleWidget != null) {
      children.add(titleWidget!);
    }

    if (title != null) {
      if (titleWidget != null) {
        children.add(const SizedBox(height: Spacing.xs));
      }
      children.add(
        Text(
          title!,
          style: getBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: titleFontSize ?? FontSize.size16,
            color: titleColor ?? color.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (subtitle != null) {
      children.add(const SizedBox(height: Spacing.border));
      children.add(_buildSubtitleWidget(context, color));
    }

    if (children.length == 1) {
      return children.first;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildSubtitleWidget(BuildContext context, ColorScheme color) {
    if (useSubtitleBadge || subtitleIcon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.border,
        ),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Spacing.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              subtitleIcon ?? Icons.filter_alt,
              size: 12,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                subtitle!,
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  color: subtitleColor ?? color.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      subtitle!,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: getRegularStyle(
        fontFamily: FontConstant.alexandria,
        fontSize: FontSize.size10,
        color: subtitleColor ?? color.onSurfaceVariant,
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return null;
    return actions!.map((w) => Center(child: w)).toList();
  }
}
