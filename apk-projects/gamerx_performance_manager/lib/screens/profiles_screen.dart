import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/app_theme.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen>
    with TickerProviderStateMixin {
  String _currentProfile = 'Balanced';
  bool _isApplying = false;
  late AnimationController _pulseController;

  final List<ProfileData> _profiles = [
    ProfileData(
      name: 'Battery Saver',
      emoji: '🔋',
      color: AppTheme.success,
      description: 'Maximum battery life',
      features: ['Low CPU', 'Power Efficient', 'Extended Battery'],
    ),
    ProfileData(
      name: 'Balanced',
      emoji: '⚖️',
      color: AppTheme.info,
      description: 'Optimal performance',
      features: ['Balanced CPU', 'Smart GPU', 'Good Battery'],
    ),
    ProfileData(
      name: 'Gaming',
      emoji: '🎮',
      color: Color(0xFFf97316),
      description: 'Performance focused',
      features: ['High CPU', 'Max GPU', 'Fast Response'],
    ),
    ProfileData(
      name: 'Turbo Gaming',
      emoji: '🚀',
      color: AppTheme.error,
      description: 'Maximum performance',
      features: ['Max CPU', 'Turbo GPU', 'Ultimate Power'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      // First try shared location (for Quick Settings sync)
      final sharedResult = await Process.run(
        'sh',
        ['-c', 'cat /data/local/tmp/gamerx_current_profile.txt 2>/dev/null'],
      );
      
      if (sharedResult.exitCode == 0 && sharedResult.stdout.toString().trim().isNotEmpty) {
        setState(() {
          _currentProfile = sharedResult.stdout.toString().trim();
        });
        return;
      }
      
      // Fallback to app storage
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/current_profile.txt');

      if (await file.exists()) {
        final savedProfile = await file.readAsString();
        setState(() {
          _currentProfile = savedProfile.trim();
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _applyProfile(String profileName) async {
    if (_isApplying) return;

    // Store previous profile for rollback
    final previousProfile = _currentProfile;

    // INSTANT UI UPDATE - Update immediately before script runs
    setState(() {
      _currentProfile = profileName;
      _isApplying = true;
    });

    // Show instant feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Applying $profileName...'),
            ],
          ),
          backgroundColor: AppTheme.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }

    // Run script in background
    try {
      String engineProfile = profileName.toLowerCase().replaceAll(' ', '_');

      final result = await Process.run(
        'su',
        ['-c', '/system/bin/gamerx_perf_engine apply $engineProfile'],
      );

      if (result.exitCode == 0) {
        // Save to app storage
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/current_profile.txt');
        await file.writeAsString(profileName);

        // Save to shared location (for Quick Settings sync)
        await Process.run('su', [
          '-c',
          'echo "$profileName" > /data/local/tmp/gamerx_current_profile.txt && chmod 666 /data/local/tmp/gamerx_current_profile.txt'
        ]);

        if (mounted) {
          _showSuccessSnackbar(profileName);
        }
      } else {
        // Rollback UI on failure
        setState(() {
          _currentProfile = previousProfile;
        });
        
        if (mounted) {
          _showErrorSnackbar('Failed to apply profile');
        }
      }
    } catch (e) {
      // Rollback UI on error
      setState(() {
        _currentProfile = previousProfile;
      });
      
      debugPrint('Error applying profile: $e');
      if (mounted) {
        _showErrorSnackbar('Error: $e');
      }
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }

  void _showSuccessSnackbar(String profileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Applied $profileName profile',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildStatusCard(),
                  const SizedBox(height: 32),
                  Text(
                    'Performance Profiles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your performance mode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildProfileCard(_profiles[index], index);
                },
                childCount: _profiles.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final currentProfileData = _profiles.firstWhere(
      (p) => p.name == _currentProfile,
      orElse: () => _profiles[1],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassEffect(opacity: 0.05).copyWith(
        gradient: LinearGradient(
          colors: [
            currentProfileData.color.withOpacity(0.15),
            currentProfileData.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: currentProfileData.color.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Profile',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentProfile,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: currentProfileData.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentProfileData.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.15),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        currentProfileData.color,
                        currentProfileData.color.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentProfileData.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentProfileData.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms);
  }

  Widget _buildProfileCard(ProfileData profile, int index) {
    final isSelected = profile.name == _currentProfile;
    final isApplying = _isApplying && profile.name != _currentProfile;

    return GestureDetector(
      onTap: isApplying ? null : () => _applyProfile(profile.name),
      child: Container(
        decoration: AppTheme.cardDecoration(
          borderColor: isSelected ? profile.color : profile.color.withOpacity(0.3),
          borderWidth: isSelected ? 3 : 2,
          withShadow: isSelected,
        ).copyWith(
          color: AppTheme.cardDark,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: profile.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        profile.color.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [profile.color, profile.color.withOpacity(0.6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: profile.color.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  
                  // Title and Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? profile.color : Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? profile.color.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: isSelected
                            ? profile.color.withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'ACTIVE' : 'TAP TO APPLY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? profile.color : AppTheme.textTertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .slideY(begin: 0.2, end: 0);
  }
}

class ProfileData {
  final String name;
  final String emoji;
  final Color color;
  final String description;
  final List<String> features;

  ProfileData({
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.features,
  });
}
