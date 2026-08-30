import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/device_model.dart';

/// Reusable device connectivity indicator displaying live ESP32 status and last sync time.
class DeviceStatusIndicator extends StatelessWidget {
  final DeviceModel? device;
  final VoidCallback? onRefresh;

  const DeviceStatusIndicator({
    super.key,
    this.device,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = device?.isConnected ?? false;
    final statusColor = isConnected ? AppColors.deviceConnected : AppColors.deviceOffline;
    final statusText = isConnected ? 'Connected' : 'Device Offline';
    final syncText = device != null
        ? DateFormatter.formatLastSync(device!.lastSeen)
        : 'Awaiting device sync';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (isConnected)
                  BoxShadow(
                    color: statusColor.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      statusText,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 13,
                        color: isConnected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    if (device != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${device!.deviceName})',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ],
                ),
                Text(
                  syncText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              color: AppColors.textSecondary,
              onPressed: onRefresh,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
