import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../notifications/logic/notifications_controller.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'vehicles_home_page.dart';
import 'maps_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // استخدام const للحفاظ على حالة الصفحات
  final List<Widget> _pages = [
    const VehiclesHomePage(),
    const MapsPage(),
    const NotificationsPage(),
    const SettingsPage(),
  ];

  void _onTabChanged(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // IndexedStack يحافظ على حالة الصفحات (scroll position, state, etc.)
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : AppColors.primary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.translate('home'),
                isSelected: _selectedIndex == 0,
                onTap: () => _onTabChanged(0),
              ),
              _NavItem(
                icon: Icons.map_rounded,
                label: l10n.translate('maps'),
                isSelected: _selectedIndex == 1,
                onTap: () => _onTabChanged(1),
              ),
              Consumer<NotificationsController>(
                builder: (context, controller, child) {
                  return _NavItem(
                    icon: Icons.notifications_rounded,
                    label: 'الإشعارات',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onTabChanged(2),
                    badgeCount: controller.unreadCount,
                  );
                },
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: l10n.translate('settings'),
                isSelected: _selectedIndex == 3,
                onTap: () => _onTabChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Material + InkWell للحصول على تأثير Ripple ودعم Accessibility
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text('$badgeCount'),
                backgroundColor: isSelected ? AppColors.primary : Colors.red,
                textColor: isSelected ? Colors.white : Colors.white,
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : Colors.white70,
                ),
              ),
              // AnimatedSize لانتقال سلس عند ظهور/إخفاء النص
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
