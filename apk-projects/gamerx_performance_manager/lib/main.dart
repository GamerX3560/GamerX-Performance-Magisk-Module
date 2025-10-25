import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/profiles_screen.dart';
import 'screens/monitor_screen.dart';
import 'screens/system_info_screen.dart';
import 'screens/about_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const GamerXApp());
}

class GamerXApp extends StatelessWidget {
  const GamerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0a0a0a),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: 'GamerX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _drawerController;

  final List<Widget> _screens = [
    const ProfilesScreen(),
    const MonitorScreen(),
    const SystemInfoScreen(),
    const AboutScreen(),
  ];

  final List<DrawerItem> _drawerItems = [
    DrawerItem(icon: Icons.dashboard_rounded, title: 'Profiles', index: 0),
    DrawerItem(icon: Icons.monitor_heart_rounded, title: 'Monitor', index: 1),
    DrawerItem(icon: Icons.info_rounded, title: 'System Info', index: 2),
    DrawerItem(icon: Icons.account_circle_rounded, title: 'About', index: 3),
  ];

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('main_scaffold'),
      extendBodyBehindAppBar: true,
      drawer: _buildModernDrawer(),
      appBar: _buildModernAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          decoration: AppTheme.backgroundGradient,
          child: _screens[_selectedIndex],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    final titles = ['GamerX', 'Monitor', 'System Info', 'About'];
    
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, size: 28),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
      ),
      title: Text(
        titles[_selectedIndex],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 1000.ms),
      ],
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0f0f0f),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0f0f0f),
              const Color(0xFF1a1a1a).withOpacity(0.8),
              const Color(0xFF0f0f0f),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, index) {
                    return _buildDrawerItem(_drawerItems[index], index);
                  },
                ),
              ),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 2000.ms),
          const SizedBox(height: 16),
          const Text(
            'GamerX',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 4),
          Text(
            'Performance Manager',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(DrawerItem item, int index) {
    final isSelected = _selectedIndex == item.index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedIndex = item.index;
            });
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected 
                  ? AppTheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primary.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppTheme.primary : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : Colors.white70,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
          const SizedBox(height: 12),
          Text(
            'v2.23 Enhanced',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final int index;

  DrawerItem({required this.icon, required this.title, required this.index});
}
