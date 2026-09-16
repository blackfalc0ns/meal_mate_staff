import 'package:flutter/material.dart';

import '../../../features/auth/domain/user_role.dart';
import '../../../features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart';
import '../../../features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart';
import '../../../features/dispatcher/dispatcher_orders/presentation/screens/dispatcher_orders_screen.dart';
import '../../../features/dispatcher/dispatcher_profile/presentation/screens/dispatcher_profile_screen.dart';
import '../../../features/dispatcher/dispatcher_support/presentation/screens/dispatcher_support_screen.dart';
import '../../../features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
import '../../extensions/extensions.dart';
import '../widgets/app_bottom_nav_bar.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    this.role = UserRole.operations,
    this.pages = const [],
    this.body,
    this.initialIndex = 0,
    this.selectedIndex,
    this.onItemSelected,
  });

  final UserRole role;
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
    if (widget.role == UserRole.driver) {
      return [
        const DriverAssignedBoxesScreen(),
        const DriverAssignedBoxesScreen(),
        const Text("Map"),
        const Text("Support"),
        const Text("Profile"),
      ];
    }
    return [
      const DispatcherHomeScreen(),
      const DispatcherOrdersScreen(),
      const DispatcherMapScreen(),
      const DispatcherSupportScreen(),
      const DispatcherProfileScreen(showBackButton: false),
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
      extendBody: true,
      body: content,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: activeIndex,
        onItemSelected: _handleItemSelected,
      ),
    );
  }
}
