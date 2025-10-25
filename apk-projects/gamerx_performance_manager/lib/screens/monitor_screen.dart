import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:io';
import '../utils/app_theme.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with TickerProviderStateMixin {
  Timer? _updateTimer;
  late AnimationController _refreshController;

  // System Stats
  String _cpuUsage = '0';
  List<String> _cpuFreqs = []; // All CPU core frequencies
  String _cpuTemp = '0';
  String _gpuFreq = '0';
  String _ramUsed = '0';
  String _ramTotal = '4096';
  String _thermalTemp = '0';
  bool _isLoading = true;
  int _cpuCoreCount = 0;
  
  // Previous CPU stats for usage calculation
  List<int>? _prevCpuStats;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _startMonitoring();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  void _startMonitoring() {
    _fetchSystemStats();
    // Increase interval to reduce lag and root prompts
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _fetchSystemStats();
      }
    });
  }

  Future<void> _fetchSystemStats() async {
    try {
      // Get CPU core count first
      final coresRaw = await _execCommand('cat /proc/cpuinfo | grep processor | wc -l');
      _cpuCoreCount = int.tryParse(coresRaw) ?? 4;

      // CPU Usage (from /proc/stat) - More accurate calculation
      final cpuStat = await _execCommand('cat /proc/stat | grep "^cpu " | head -1');
      await _calculateCpuUsage(cpuStat);

      // ALL CPU Core Frequencies
      _cpuFreqs.clear();
      for (int i = 0; i < _cpuCoreCount; i++) {
        final freqRaw = await _execCommand(
            'cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null');
        if (freqRaw.isNotEmpty && freqRaw != '') {
          try {
            final freqMhz = (int.parse(freqRaw) / 1000).toStringAsFixed(0);
            _cpuFreqs.add(freqMhz);
          } catch (e) {
            _cpuFreqs.add('0');
          }
        } else {
          _cpuFreqs.add('--');
        }
      }

      // CPU Temperature (try multiple paths)
      _cpuTemp = await _getCpuTemp();

      // GPU Frequency
      _gpuFreq = await _getGpuFreq();

      // RAM Info
      final memInfo = await _execCommand('cat /proc/meminfo');
      _parseMemInfo(memInfo);

      // Thermal Temperature (try multiple methods)
      _thermalTemp = await _getThermalTemp();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching stats: $e');
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
      return '';
    }
  }

  Future<void> _calculateCpuUsage(String cpuStat) async {
    try {
      final parts = cpuStat.trim().split(RegExp(r'\s+'));
      if (parts.length < 5) return;
      
      // Parse: cpu user nice system idle iowait irq softirq
      final values = parts.skip(1).take(7).map((e) => int.tryParse(e) ?? 0).toList();
      if (values.length < 4) return;
      
      final idle = values[3] + (values.length > 4 ? values[4] : 0); // idle + iowait
      final total = values.reduce((a, b) => a + b);
      
      if (_prevCpuStats != null && _prevCpuStats!.length == 2) {
        final prevIdle = _prevCpuStats![0];
        final prevTotal = _prevCpuStats![1];
        
        final diffIdle = idle - prevIdle;
        final diffTotal = total - prevTotal;
        
        if (diffTotal > 0) {
          final usage = ((diffTotal - diffIdle) / diffTotal * 100);
          _cpuUsage = usage.clamp(0, 100).toStringAsFixed(1);
        }
      }
      
      _prevCpuStats = [idle, total];
    } catch (e) {
      debugPrint('CPU usage calc error: $e');
    }
  }

  Future<String> _getCpuTemp() async {
    try {
      // Method 1: Try thermal zones with type checking
      for (int i = 0; i < 15; i++) {
        final type = await _execCommand(
            'cat /sys/class/thermal/thermal_zone$i/type 2>/dev/null');
        // Look for CPU-related thermal zones
        if (type.toLowerCase().contains('cpu') || 
            type.toLowerCase().contains('tsens') ||
            type.toLowerCase().contains('soc')) {
          final temp = await _execCommand(
              'cat /sys/class/thermal/thermal_zone$i/temp 2>/dev/null');
          final tempInt = int.tryParse(temp);
          if (tempInt != null && tempInt > 0) {
            if (tempInt > 1000) {
              return (tempInt / 1000).toStringAsFixed(0);
            } else if (tempInt > 0 && tempInt < 200) {
              return tempInt.toString();
            }
          }
        }
      }
      
      // Method 2: Try any thermal zone with reasonable temp
      for (int i = 0; i < 15; i++) {
        final temp = await _execCommand(
            'cat /sys/class/thermal/thermal_zone$i/temp 2>/dev/null');
        final tempInt = int.tryParse(temp);
        if (tempInt != null && tempInt > 1000 && tempInt < 200000) {
          return (tempInt / 1000).toStringAsFixed(0);
        }
      }
    } catch (e) {
      debugPrint('CPU temp error: $e');
    }
    return '0';
  }
  
  Future<String> _getThermalTemp() async {
    try {
      // Find highest thermal zone temp (NO ROOT - direct sysfs read)
      int maxTemp = 0;
      for (int i = 0; i < 15; i++) {
        final temp = await _execCommand(
            'cat /sys/class/thermal/thermal_zone$i/temp 2>/dev/null');
        final tempInt = int.tryParse(temp);
        if (tempInt != null && tempInt > maxTemp && tempInt < 200000) {
          maxTemp = tempInt;
        }
      }
      
      if (maxTemp > 1000) {
        return (maxTemp / 1000).toStringAsFixed(0);
      } else if (maxTemp > 0) {
        return maxTemp.toString();
      }
    } catch (e) {
      debugPrint('Thermal temp error: $e');
    }
    return '0';
  }

  Future<String> _getGpuFreq() async {
    try {
      // Try Qualcomm Adreno GPU
      final freq = await _execCommand(
          'cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null');
      if (freq.isNotEmpty) {
        return (int.parse(freq) / 1000000).toStringAsFixed(0);
      }
    } catch (e) {
      // Ignore
    }
    return '0';
  }

  void _parseMemInfo(String memInfo) {
    try {
      final lines = memInfo.split('\n');
      for (final line in lines) {
        if (line.startsWith('MemTotal:')) {
          final total = int.parse(line.split(RegExp(r'\s+'))[1]);
          _ramTotal = (total / 1024).toStringAsFixed(0);
        } else if (line.startsWith('MemAvailable:')) {
          final available = int.parse(line.split(RegExp(r'\s+'))[1]);
          final total = int.parse(_ramTotal) * 1024;
          _ramUsed = ((total - available) / 1024).toStringAsFixed(0);
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _refreshController.forward(from: 0);
          await _fetchSystemStats();
        },
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardDark,
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
                      'System Performance',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time hardware monitoring',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatCard(
                    'CPU Usage',
                    _cpuUsage,
                    '%',
                    Icons.memory_rounded,
                    AppTheme.primary,
                    0,
                  ),
                  const SizedBox(height: 16),
                  _buildCpuFrequencyCard(1),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'CPU Temperature',
                    _cpuTemp,
                    '°C',
                    Icons.thermostat_rounded,
                    _getTempColor(int.tryParse(_cpuTemp) ?? 0),
                    2,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'GPU Frequency',
                    _gpuFreq,
                    'MHz',
                    Icons.videogame_asset_rounded,
                    AppTheme.accent,
                    3,
                  ),
                  const SizedBox(height: 16),
                  _buildRAMCard(4),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Thermal',
                    _thermalTemp,
                    '°C',
                    Icons.device_thermostat_rounded,
                    _getTempColor(int.tryParse(_thermalTemp) ?? 0),
                    5,
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTempColor(int temp) {
    if (temp >= 70) return AppTheme.error;
    if (temp >= 60) return AppTheme.warning;
    return AppTheme.success;
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassEffect(opacity: 0.05).copyWith(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.15),
            AppTheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.4),
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
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Colors.black,
              size: 28,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(duration: 2000.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Monitoring',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.success,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.success.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeOut(duration: 1000.ms)
                        .then()
                        .fadeIn(duration: 1000.ms),
                    const SizedBox(width: 8),
                    Text(
                      'Updates every 2s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms);
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    int index,
  ) {
    if (_isLoading) {
      return _buildShimmerCard();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(
        borderColor: color.withOpacity(0.3),
        borderWidth: 2,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        unit,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                      ),
                    ),
                  ],
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

  Widget _buildRAMCard(int index) {
    if (_isLoading) {
      return _buildShimmerCard();
    }

    final ramUsedInt = int.tryParse(_ramUsed) ?? 0;
    final ramTotalInt = int.tryParse(_ramTotal) ?? 4096;
    final percentage = (ramUsedInt / ramTotalInt * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(
        borderColor: AppTheme.secondary.withOpacity(0.3),
        borderWidth: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.memory, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RAM Usage',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          percentage,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '%',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ramUsedInt / ramTotalInt,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_ramUsed MB / $_ramTotal MB',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildCpuFrequencyCard(int index) {
    if (_isLoading) {
      return _buildShimmerCard();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(
        borderColor: AppTheme.info.withOpacity(0.3),
        borderWidth: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.info, AppTheme.info.withOpacity(0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.info.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.speed_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CPU Frequencies',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_cpuCoreCount Cores',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.info,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_cpuFreqs.length, (i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CPU$i',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _cpuFreqs[i],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'MHz',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardDark,
      highlightColor: AppTheme.surfaceDark,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
