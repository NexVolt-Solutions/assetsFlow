import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

enum RepairStatus { inRepair, fixed, notRepairable }

extension RepairStatusX on RepairStatus {
  String get label {
    switch (this) {
      case RepairStatus.inRepair:
        return 'In Repair';
      case RepairStatus.fixed:
        return 'Fixed';
      case RepairStatus.notRepairable:
        return 'Not Repairable';
    }
  }
}

class RepairEntry {
  final String id;
  final String name;
  final String assetId;
  final String model;
  final String sentForRepairDate;
  final RepairStatus status;

  RepairEntry({
    required this.id,
    required this.name,
    required this.assetId,
    required this.model,
    required this.sentForRepairDate,
    required this.status,
  });

  RepairEntry copyWith({RepairStatus? status}) => RepairEntry(
    id: id,
    name: name,
    assetId: assetId,
    model: model,
    sentForRepairDate: sentForRepairDate,
    status: status ?? this.status,
  );
}

List<RepairEntry> get kDemoRepairEntries => [
  RepairEntry(
    id: 'r1',
    name: 'HP EliteBook 840',
    assetId: 'LP-2024-007',
    model: 'HP EliteBook 840 G9',
    sentForRepairDate: '2024-12-10',
    status: RepairStatus.inRepair,
  ),
];

class RepairManagementScreenContent extends StatefulWidget {
  const RepairManagementScreenContent({super.key});

  @override
  State<RepairManagementScreenContent> createState() =>
      _RepairManagementScreenContentState();
}

class _RepairManagementScreenContentState
    extends State<RepairManagementScreenContent> {
  late List<RepairEntry> _repairList = List.from(kDemoRepairEntries);

  int get _inRepairCount =>
      _repairList.where((e) => e.status == RepairStatus.inRepair).length;

  void _updateStatus(RepairEntry entry, RepairStatus newStatus) {
    setState(() {
      final i = _repairList.indexWhere((e) => e.id == entry.id);
      if (i >= 0) _repairList[i] = entry.copyWith(status: newStatus);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.name} marked as ${newStatus.label}'),
        backgroundColor: _snackBarColorForStatus(newStatus),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _snackBarColorForStatus(RepairStatus status) {
    switch (status) {
      case RepairStatus.inRepair:
        return AppColors.sendToRepairButtonBg;
      case RepairStatus.fixed:
        return AppColors.repairFixedIconGreen;
      case RepairStatus.notRepairable:
        return AppColors.removeButtonBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.w(24),
        0,
        context.w(24),
        context.h(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repair Management',
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(24),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            '$_inRepairCount assets currently under repair',
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: context.h(24)),
          _buildStatusLegend(context),
          SizedBox(height: context.h(20)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _repairList.length,
            itemBuilder: (context, index) {
              final entry = _repairList[index];
              return Padding(
                key: ValueKey(entry.id),
                padding: EdgeInsets.only(bottom: context.h(16)),
                child: RepairAssetCard(
                  entry: entry,
                  onMarkFixed: () => _updateStatus(entry, RepairStatus.fixed),
                  onUnderRepair: () =>
                      _updateStatus(entry, RepairStatus.inRepair),
                  onNotRepairable: () =>
                      _updateStatus(entry, RepairStatus.notRepairable),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(BuildContext context) {
    return Row(
      children: [
        _StatusLegendItem(
          icon: Icons.schedule,
          iconColor: AppColors.sendToRepairButtonBg,
          label: 'In Repair',
        ),
        SizedBox(width: context.w(24)),
        _StatusLegendItem(
          icon: Icons.check_circle,
          iconColor: AppColors.repairFixedIconGreen,
          label: 'Fixed',
        ),
        SizedBox(width: context.w(24)),
        _StatusLegendItem(
          icon: Icons.cancel,
          iconColor: AppColors.removeButtonBg,
          label: 'Not Repairable',
        ),
      ],
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatusLegendItem({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        SizedBox(width: context.w(8)),
        Text(
          label,
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class RepairAssetCard extends StatelessWidget {
  final RepairEntry entry;
  final VoidCallback onMarkFixed;
  final VoidCallback onUnderRepair;
  final VoidCallback onNotRepairable;

  const RepairAssetCard({
    super.key,
    required this.entry,
    required this.onMarkFixed,
    required this.onUnderRepair,
    required this.onNotRepairable,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: context.padAll(16),
      decoration: BoxDecoration(
        color: AppColors.assignCardBg,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: isNarrow ? _buildColumnLayout(context) : _buildRowLayout(context),
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(context),
        SizedBox(width: context.w(16)),
        Expanded(child: _buildDetails(context)),
        SizedBox(width: context.w(16)),
        Wrap(
          spacing: context.w(8),
          runSpacing: context.h(8),
          alignment: WrapAlignment.end,
          children: _buildButtons(),
        ),
      ],
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(context),
            SizedBox(width: context.w(16)),
            Expanded(child: _buildDetails(context)),
          ],
        ),
        SizedBox(height: context.h(12)),
        Wrap(
          spacing: context.w(8),
          runSpacing: context.h(8),
          children: _buildButtons(),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.listAvatarBg,
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: Icon(
        Icons.laptop_mac,
        color: AppColors.sendToRepairButtonBg,
        size: 28,
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          entry.name,
          style: TextStyle(
            color: AppColors.headingColor,
            fontSize: context.text(16),
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.h(4)),
        Text(
          '${entry.assetId} · ${entry.model}',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(13),
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.h(4)),
        Text(
          'Sent for repair: ${entry.sentForRepairDate}',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(12),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildButtons() => [
    _ActionButton(
      label: 'Mark Fixed',
      backgroundColor: AppColors.repairMarkFixedBg,
      onTap: onMarkFixed,
    ),
    _ActionButton(
      label: 'Under Repair',
      backgroundColor: AppColors.sendToRepairButtonBg,
      onTap: onUnderRepair,
    ),
    _ActionButton(
      label: 'Not Repairable',
      backgroundColor: AppColors.removeButtonBg,
      onTap: onNotRepairable,
    ),
  ];
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: Container(
          padding: context.padSym(h: 10, v: 6),
          decoration: BoxDecoration(
            border: Border.all(color: backgroundColor, width: 1),
            color: backgroundColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(context.radius(22)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: backgroundColor,
              fontSize: context.text(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
