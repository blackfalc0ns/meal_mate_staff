import 'package:flutter/material.dart';

import '../../../features/dispatcher/home/presentation/screens/dispatcher_home_screen.dart';
import '../../../features/dispatcher/map/presentation/screens/dispatcher_map_screen.dart';
import '../../../features/dispatcher/orders/presentation/screens/dispatcher_orders_screen.dart';
import '../../../features/dispatcher/profile/presentation/screens/dispatcher_profile_screen.dart';
import '../../../features/dispatcher/support/presentation/screens/dispatcher_support_screen.dart';
import '../../extensions/extensions.dart';
import '../widgets/app_bottom_nav_bar.dart';

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
    return [
      const DispatcherHomeScreen(),
      const DispatcherOrdersScreen(showBottomNavBar: false),
      const DispatcherMapScreen(showBottomNavBar: false),
      const DispatcherSupportScreen(showBottomNavBar: false),
      const DispatcherProfileScreen(
        showBackButton: false,
        showBottomNavBar: false,
      ),
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
