import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../utils/app_theme.dart';

class SystemInfoScreen extends StatefulWidget {
  const SystemInfoScreen({super.key});

  @override
  State<SystemInfoScreen> createState() => _SystemInfoScreenState();
}

class _SystemInfoScreenState extends State<SystemInfoScreen> {
  Map<String, String> _systemInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Execute system commands
      final kernelVersion = await _execCommand('uname -r');
      final androidVersion = androidInfo.version.release;
      final sdkVersion = androidInfo.version.sdkInt.toString();
      final manufacturer = androidInfo.manufacturer;
      final model = androidInfo.model;
      final brand = androidInfo.brand;
      final device = androidInfo.device;
      final board = androidInfo.board;
      final bootloader = androidInfo.bootloader.isNotEmpty ? androidInfo.bootloader : 'N/A';
      final fingerprint = androidInfo.fingerprint;
      final display = androidInfo.display;
      
      // Get CPU cores
      final cpuCores = await _execCommand('cat /proc/cpuinfo | grep processor | wc -l');
      
      // Get total RAM
      final ramInfo = await _execCommand('cat /proc/meminfo | grep MemTotal');
      final ramMB = _parseRam(ramInfo);
      
      // Get SoC - Try multiple methods
      final socType = await _getSoCType();
      
      // Get root method - Try multiple methods
      final rootMethod = await _getRootMethod();
      
      setState(() {
        _systemInfo = {
          'Device Model': '$manufacturer $model',
          'Brand': brand,
          'Device': device,
          'Board': board,
          'Android Version': androidVersion,
          'SDK Version': sdkVersion,
          'Kernel Version': kernelVersion,
          'SoC': socType,
          'CPU Cores': cpuCores,
          'Total RAM': ramMB,
          'Bootloader': bootloader,
          'Display': display,
          'Root Method': rootMethod,
          'Build Fingerprint': fingerprint,
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading system info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _execCommand(String command) async {
    try {
      final result = await Process.run('sh', ['-c', command]);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'N/A';
    }
  }

  String _parseRam(String ramInfo) {
    try {
      final match = RegExp(r'(\d+)').firstMatch(ramInfo);
      if (match != null) {
        final kb = int.parse(match.group(1)!);
        return '${(kb / 1024 / 1024).toStringAsFixed(2)} GB';
      }
    } catch (e) {
      // Ignore
    }
    return 'Unknown';
  }

  Future<String> _getSoCType() async {
    try {
      // Method 1: Try /proc/cpuinfo Hardware field (NO ROOT)
      final cpuInfo = await _execCommand('cat /proc/cpuinfo | grep "Hardware" | head -1');
      if (cpuInfo.contains(':')) {
        final hardware = cpuInfo.split(':').last.trim();
        if (hardware.isNotEmpty) {
          return hardware;
        }
      }
      
      // Method 2: Try ro.hardware.chipset
      final chipset = await _execCommand('getprop ro.hardware.chipset');
      if (chipset.isNotEmpty) return chipset;
      
      // Method 3: Try ro.board.platform
      final platform = await _execCommand('getprop ro.board.platform');
      if (platform.isNotEmpty) return platform;
      
      // Method 4: Try ro.hardware
      final hardware = await _execCommand('getprop ro.hardware');
      if (hardware.isNotEmpty) return hardware;
      
    } catch (e) {
      debugPrint('SoC detection error: $e');
    }
    return 'Unknown';
  }

  Future<String> _getRootMethod() async {
    try {
      // Method 1: Check Magisk (most common)
      final magiskVersion = await _execCommand('magisk -V 2>/dev/null');
      if (magiskVersion.isNotEmpty) {
        return 'Magisk $magiskVersion';
      }
      
      // Method 2: Check KernelSU
      final ksuVersion = await _execCommand('ksud -V 2>/dev/null');
      if (ksuVersion.isNotEmpty) {
        return 'KernelSU $ksuVersion';
      }
      
      // Method 3: Check APatch
      if (await _execCommand('[ -d "/data/adb/ap" ] && echo "yes"') == 'yes') {
        return 'APatch';
      }
      
      // Method 4: Check if rooted (simplified - ONE su call)
      final hasRoot = await _execCommand('su -c "echo rooted" 2>/dev/null');
      if (hasRoot.contains('rooted')) {
        return 'Rooted';
      }
      
    } catch (e) {
      debugPrint('Root detection error: $e');
    }
    return 'Not Detected';
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
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Device Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Complete system specifications',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entries = _systemInfo.entries.toList();
                    final entry = entries[index];
                    return _buildInfoCard(
                      entry.key,
                      entry.value,
                      _getIconForKey(entry.key),
                      _getColorForKey(entry.key),
                      index,
                    );
                  },
                  childCount: _systemInfo.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassEffect(opacity: 0.05).copyWith(
        gradient: LinearGradient(
          colors: [
            AppTheme.info.withOpacity(0.15),
            AppTheme.info.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.info.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.info, AppTheme.info.withOpacity(0.6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.info.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Info',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hardware & Software Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms);
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(
        borderColor: color.withOpacity(0.2),
        borderWidth: 1.5,
        withShadow: false,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.2, end: 0);
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'Device Model':
        return Icons.phone_android_rounded;
      case 'Brand':
        return Icons.branding_watermark_rounded;
      case 'Android Version':
        return Icons.android_rounded;
      case 'Kernel Version':
        return Icons.code_rounded;
      case 'SoC':
        return Icons.memory_rounded;
      case 'CPU Cores':
        return Icons.speed_rounded;
      case 'Total RAM':
        return Icons.storage_rounded;
      case 'Root Method':
        return Icons.verified_user_rounded;
      case 'Display':
        return Icons.screenshot_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColorForKey(String key) {
    switch (key) {
      case 'Device Model':
      case 'Brand':
        return AppTheme.primary;
      case 'Android Version':
      case 'SDK Version':
        return AppTheme.success;
      case 'SoC':
      case 'CPU Cores':
        return AppTheme.info;
      case 'Total RAM':
        return AppTheme.secondary;
      case 'Root Method':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }
}
