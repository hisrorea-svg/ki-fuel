import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // اهتزاز خفيف عند تغيير التاب
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // ألوان على طراز فيسبوك
    final navBgColor = isDark ? const Color(0xFF242526) : Colors.white;
    final activeColor = isDark ? const Color(0xFF2D88FF) : AppColors.primary;
    final inactiveColor = isDark
        ? const Color(0xFFB0B3B8)
        : const Color(0xFF65676B);
    final indicatorColor = activeColor;

    return Scaffold(
      // IndexedStack يحافظ على حالة الصفحات (scroll position, state, etc.)
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                _FacebookNavItem(
                  icon: Icons.home_rounded,
                  iconOutlined: Icons.home_outlined,
                  label: l10n.translate('home'),
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onTabChanged(0),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  indicatorColor: indicatorColor,
                ),
                _FacebookNavItem(
                  icon: Icons.map_rounded,
                  iconOutlined: Icons.map_outlined,
                  label: l10n.translate('maps'),
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onTabChanged(1),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  indicatorColor: indicatorColor,
                ),
                Consumer<NotificationsController>(
                  builder: (context, controller, child) {
                    return _FacebookNavItem(
                      icon: Icons.notifications_rounded,
                      iconOutlined: Icons.notifications_outlined,
                      label: l10n.translate('notifications'),
                      isSelected: _selectedIndex == 2,
                      onTap: () => _onTabChanged(2),
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      indicatorColor: indicatorColor,
                      badgeCount: controller.unreadCount,
                    );
                  },
                ),
                _FacebookNavItem(
                  icon: Icons.menu_rounded,
                  iconOutlined: Icons.menu_rounded,
                  label: l10n.translate('settings'),
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onTabChanged(3),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  indicatorColor: indicatorColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// عنصر التنقل على طراز فيسبوك
class _FacebookNavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final int badgeCount;

  const _FacebookNavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: activeColor.withValues(alpha: 0.1),
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // خط المؤشر العلوي (على طراز فيسبوك)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                height: 3,
                width: isSelected ? 32 : 0,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // الأيقونة مع البادج
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isSelected ? icon : iconOutlined,
                        key: ValueKey(isSelected),
                        size: 26,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                    ),
                    // البادج للإشعارات
                    if (badgeCount > 0)
                      Positioned(
                        top: -6,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // النص (اختياري - يمكن إخفاءه للحصول على مظهر أكثر نظافة)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
