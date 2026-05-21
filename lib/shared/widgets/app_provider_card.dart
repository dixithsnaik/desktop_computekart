import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppProviderCard extends StatefulWidget {
  final Map<String, dynamic> provider;
  final bool isActive;
  final AppPalette palette;
  final bool isDark;
  final VoidCallback? onEdit;

  const AppProviderCard({
    super.key,
    required this.provider,
    this.isActive = false,
    required this.palette,
    required this.isDark,
    this.onEdit,
  });

  @override
  State<AppProviderCard> createState() => _AppProviderCardState();
}

class _AppProviderCardState extends State<AppProviderCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final details = <MapEntry<String, String>>[
      if (widget.provider['providerAllowedVcpu'] != null)
        MapEntry('Max vCPUs', '${widget.provider['providerAllowedVcpu']} vCPUs'),
      if (widget.provider['providerAllowedRam'] != null)
        MapEntry('Max RAM', '${(int.tryParse(widget.provider['providerAllowedRam'].toString()) ?? 0) ~/ 1024} GB'),
      if (widget.provider['providerAllowedStorage'] != null)
        MapEntry('Max Storage', '${(int.tryParse(widget.provider['providerAllowedStorage'].toString()) ?? 0) ~/ 1024} GB'),
      if (widget.provider['providerStatus'] != null)
        MapEntry('Status', '${widget.provider['providerStatus']}'),
      if (widget.provider['providerAllowedNetworks'] != null)
        MapEntry('Max Networks', '${widget.provider['providerAllowedNetworks']} Networks'),
      if (widget.provider['providerAllowedVms'] != null)
        MapEntry('Max VMs', '${widget.provider['providerAllowedVms']} VMs'),
      if (widget.provider['providerRamCapacity'] != null)
        MapEntry('RAM Capacity', '${widget.provider['providerRamCapacity']}'),
      if (widget.provider['providerVcpuCapacity'] != null)
        MapEntry('vCPU Capacity', '${widget.provider['providerVcpuCapacity']}'),
      if (widget.provider['providerStorageCapacity'] != null)
        MapEntry('Storage Capacity', '${widget.provider['providerStorageCapacity']}'),
    ];

    final hasStatusColor = widget.provider['providerStatus'] != null;
    final isStatusActive = widget.provider['providerStatus'] == 'active' || widget.provider['providerStatus'] == true;
    final statusColor = hasStatusColor ? (isStatusActive ? AppColors.lime500 : AppColors.red500) : Colors.transparent;

    final borderColor = widget.isActive 
      ? AppColors.lime500 
      : widget.palette.border;
    
    final bgColor = widget.isActive
      ? (widget.isDark ? widget.palette.bgSurface : AppColors.lime100)
      : _hovered
        ? widget.palette.bgSurfaceMuted
        : (widget.isDark ? widget.palette.bgSurface : Colors.white);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 28), // extra right padding for the status bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Icon + Name + Edit
                  Row(
                    children: [
                      Icon(
                        Icons.computer,
                        size: 32,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.provider['providerName'] ?? '',
                          style: AppTextStyles.h3(widget.palette.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.onEdit != null)
                        InkWell(
                          onTap: widget.onEdit,
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: widget.palette.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Details Grid (2 columns)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final item = details[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: widget.palette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: AppTextStyles.bodyMedium(widget.palette.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Right Status Bar
            if (hasStatusColor)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 8,
                child: Container(
                  color: statusColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
