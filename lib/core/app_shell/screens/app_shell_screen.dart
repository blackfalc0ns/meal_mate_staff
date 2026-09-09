import 'package:flutter/material.dart';

import '../../../features/account_status/presentation/screens/account_status_preview_screen.dart';
import '../../../features/dispatcher/orders/presentation/screens/dispatcher_orders_screen.dart';
import '../../extensions/extensions.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_shell_tab_placeholder.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    this.pages = const [],
    this.body,
    this.initialIndex = 0,
    this.selectedIndex,
    this.onItemSelected,
  });

  final List<Widget> pages;
  final Widget? body;
  final int initialIndex;
  final int? selectedIndex;
  final ValueChanged<int>? onItemSelected;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex ?? widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant AppShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null && widget.selectedIndex != _currentIndex) {
      _currentIndex = widget.selectedIndex!;
    }
  }

  void _handleItemSelected(int index) {
    if (widget.selectedIndex == null && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
    widget.onItemSelected?.call(index);
  }

  List<Widget> _defaultPages(BuildContext context) {
    final locale = context.localization;

    return [
      AppShellTabPlaceholder(
        icon: Icons.storefront_outlined,
        label: locale.navHome,
      ),
      const DispatcherOrdersScreen(showBottomNavBar: false),
      AppShellTabPlaceholder(
        icon: Icons.local_shipping_outlined,
        label: locale.navDelivery,
      ),
      AppShellTabPlaceholder(
        icon: Icons.headset_mic_outlined,
        label: locale.navSupport,
      ),
      const AccountStatusPreviewScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final activeIndex = widget.selectedIndex ?? _currentIndex;

    final resolvedPages = widget.pages.isNotEmpty
        ? widget.pages
        : _defaultPages(context);

    final content =
        widget.body ??
        IndexedStack(index: activeIndex, children: resolvedPages);

    return Scaffold(
      backgroundColor: color.surface,
      body: content,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: activeIndex,
        onItemSelected: _handleItemSelected,
      ),
    );
  }
}
