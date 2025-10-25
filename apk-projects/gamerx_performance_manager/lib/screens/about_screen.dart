import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../utils/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '2.23';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAppLogo(),
                  const SizedBox(height: 32),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildFeaturesSection(),
                  const SizedBox(height: 24),
                  _buildDeveloperSection(),
                  const SizedBox(height: 24),
                  _buildCreditsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              duration: 2000.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
            )
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        const SizedBox(height: 24),
        const Text(
          'GamerX',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          'Performance Manager',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.primary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            'v$_appVersion Enhanced',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(
        borderColor: AppTheme.primary.withOpacity(0.3),
        borderWidth: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'GamerX Performance Manager is an advanced Android performance optimization tool designed to enhance your gaming and daily usage experience. '
            'Powered by a sophisticated kernel-level engine, it provides intelligent performance profiles optimized for different usage scenarios.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeaturesSection() {
    final features = [
      FeatureItem(
        icon: Icons.speed_rounded,
        title: '4 Performance Profiles',
        description: 'Battery Saver, Balanced, Gaming, and Turbo Gaming modes',
        color: AppTheme.primary,
      ),
      FeatureItem(
        icon: Icons.monitor_heart_rounded,
        title: 'Real-time Monitoring',
        description: 'Live CPU, GPU, RAM, and temperature tracking',
        color: AppTheme.info,
      ),
      FeatureItem(
        icon: Icons.memory_rounded,
        title: 'Advanced Optimization',
        description: 'RAM-aware tuning, CPU boost, and I/O scheduling',
        color: AppTheme.secondary,
      ),
      FeatureItem(
        icon: Icons.thermostat_rounded,
        title: 'Thermal Protection',
        description: 'Automatic thermal throttling for device safety',
        color: AppTheme.warning,
      ),
      FeatureItem(
        icon: Icons.security_rounded,
        title: 'Root Integration',
        description: 'Works with Magisk, KernelSU, and APatch',
        color: AppTheme.accent,
      ),
      FeatureItem(
        icon: Icons.tune_rounded,
        title: 'Universal Support',
        description: 'Optimized for Snapdragon, MediaTek, and Exynos',
        color: AppTheme.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Key Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        ...features.asMap().entries.map((entry) {
          return _buildFeatureItem(entry.value, entry.key);
        }),
      ],
    );
  }

  Widget _buildFeatureItem(FeatureItem feature, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(
        borderColor: feature.color.withOpacity(0.2),
        borderWidth: 1.5,
        withShadow: false,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [feature.color, feature.color.withOpacity(0.6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: feature.color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(feature.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildDeveloperSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(
        borderColor: AppTheme.accent.withOpacity(0.3),
        borderWidth: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.code_rounded,
                  color: AppTheme.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Developer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDeveloperInfo('Name', 'Mangesh Choudhary', Icons.person_rounded),
          const SizedBox(height: 12),
          _buildDeveloperInfoLink(
            'GitHub',
            'GamerX3560',
            Icons.code_rounded,
            'https://github.com/GamerX3560/GamerX-Performance-Magisk-Module',
          ),
          const SizedBox(height: 12),
          _buildDeveloperInfo('License', 'MIT License', Icons.badge_rounded),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDeveloperInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textTertiary, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperInfoLink(String label, String value, IconData icon, String url) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textTertiary, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            try {
              // Open URL in browser - direct am command
              final result = await Process.run('am', [
                'start',
                '-a',
                'android.intent.action.VIEW',
                '-d',
                url,
              ]);
              
              debugPrint('Browser open result: ${result.exitCode}, ${result.stdout}, ${result.stderr}');
              
              // Show success message
              if (mounted && result.exitCode == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Opening GitHub...'),
                      ],
                    ),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Error opening URL: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Error: $e')),
                      ],
                    ),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.open_in_new,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(
        borderColor: AppTheme.success.withOpacity(0.3),
        borderWidth: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppTheme.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Credits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Special thanks to:\n\n'
            '• Flutter Team - Beautiful UI framework\n'
            '• Magisk Community - Root solution\n'
            '• Android Open Source Project\n'
            '• All contributors and testers',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Made with ❤️ for the gaming community',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, end: 0);
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
