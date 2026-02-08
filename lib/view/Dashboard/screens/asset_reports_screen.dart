import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/report_model.dart';
import 'package:asset_flow/viewModel/asset_reports_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

enum ReportActionType { assigned, returned, damaged, repair }

extension ReportActionTypeX on ReportActionType {
  String get label {
    switch (this) {
      case ReportActionType.assigned:
        return 'Assigned';
      case ReportActionType.returned:
        return 'Returned';
      case ReportActionType.damaged:
        return 'Damaged';
      case ReportActionType.repair:
        return 'Repair';
    }
  }

  Color get color {
    switch (this) {
      case ReportActionType.assigned:
        return AppColors.reportPillAssigned;
      case ReportActionType.returned:
        return AppColors.reportPillReturned;
      case ReportActionType.damaged:
        return AppColors.reportPillDamaged;
      case ReportActionType.repair:
        return AppColors.reportPillRepair;
    }
  }

  Color get textColor {
    if (this == ReportActionType.returned) {
      return const Color(0xFF1a1a1a);
    }
    return color;
  }
}

ReportActionType _actionTypeFromString(String s) {
  final lower = s.trim().toLowerCase();
  switch (lower) {
    case 'assigned':
      return ReportActionType.assigned;
    case 'returned':
      return ReportActionType.returned;
    case 'damaged':
      return ReportActionType.damaged;
    case 'repair':
    case 'repaired':
      return ReportActionType.repair;
    default:
      return ReportActionType.assigned;
  }
}

class AssetReportsScreenContent extends StatefulWidget {
  const AssetReportsScreenContent({super.key});

  @override
  State<AssetReportsScreenContent> createState() =>
      _AssetReportsScreenContentState();
}

class _AssetReportsScreenContentState extends State<AssetReportsScreenContent> {
  Future<void> _downloadPdf(BuildContext context) async {
    final vm = context.read<AssetReportsScreenViewModel>();
    final period = vm.period;
    final items = vm.items;

    await pdfDefaultTheme();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Asset Reports - ${period.label}',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _pdfCell('Asset'),
                  _pdfCell('Assets Code'),
                  _pdfCell('Employee'),
                  _pdfCell('Action'),
                  _pdfCell('Date'),
                ],
              ),
              ...items.map(
                (e) => pw.TableRow(
                  children: [
                    _pdfCell('${e.assetName} (${e.assetCode})'),
                    _pdfCell(e.assetCode),
                    _pdfCell(e.employeeName),
                    _pdfCell(e.action),
                    _pdfCell(e.date),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final filename =
        'Asset_Report_${period.label}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    try {
      final ok = await Printing.sharePdf(bytes: bytes, filename: filename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'PDF ready to save or share' : 'PDF could not be shared',
            ),
            backgroundColor: ok
                ? AppColors.reportPillRepair
                : Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on MissingPluginException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Save/print is not supported on this platform. Use desktop or mobile for full support.',
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  pw.Widget _pdfCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetReportsScreenViewModel>().fetchAssetHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetReportsScreenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subHeadingColor,
                      fontSize: context.text(14),
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  TextButton.icon(
                    onPressed: vm.fetchAssetHistory,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final items = vm.items;
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
                'Asset Reports',
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(24),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: context.h(20)),
              Wrap(
                spacing: context.w(10),
                runSpacing: context.h(10),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...ReportPeriod.values.map((p) {
                    final isActive = vm.period == p;
                    return Material(
                      color: isActive
                          ? AppColors.reportFilterActiveBg
                          : AppColors.reportFilterInactiveBg,
                      borderRadius: BorderRadius.circular(context.radius(20)),
                      child: InkWell(
                        onTap: vm.isLoading ? null : () => vm.setPeriod(p),
                        borderRadius: BorderRadius.circular(context.radius(20)),
                        child: Container(
                          padding: context.padSym(h: 18, v: 10),
                          child: Text(
                            p.label,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.headingColor
                                  : AppColors.subHeadingColor,
                              fontSize: context.text(14),
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  Material(
                    color: AppColors.reportPillRepair,
                    borderRadius: BorderRadius.circular(context.radius(10)),
                    child: InkWell(
                      onTap: vm.isLoading
                          ? null
                          : () => _downloadPdf(context),
                      borderRadius: BorderRadius.circular(context.radius(10)),
                      child: Padding(
                        padding: context.padSym(h: 16, v: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download,
                              color: AppColors.headingColor,
                              size: 20,
                            ),
                            SizedBox(width: context.w(8)),
                            Text(
                              'Download PDF',
                              style: TextStyle(
                                color: AppColors.headingColor,
                                fontSize: context.text(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(28)),
              Text(
                'Asset History',
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(18),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: context.h(16)),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.assignCardBg,
                  borderRadius: BorderRadius.circular(context.radius(12)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    _buildTableHeader(context),
                    ...List.generate(items.length, (i) {
                      return _ReportRow(
                        item: items[i],
                        isStripe: i.isOdd,
                        icon: Icons.devices_other,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: context.padSym(h: 16, v: 14),
      color: AppColors.reportFilterInactiveBg,
      child: Row(
        children: [
          SizedBox(width: context.w(40)),
          Expanded(flex: 2, child: _headerText('Asset')),
          Expanded(flex: 1, child: _headerText('Assets Code')),
          Expanded(flex: 1, child: _headerText('Employee')),
          Expanded(flex: 1, child: _headerText('Action')),
          Expanded(flex: 1, child: _headerText('Date')),
        ],
      ),
    );
  }

  Widget _headerText(String label) => Text(
    label,
    style: TextStyle(
      color: AppColors.subHeadingColor,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _ReportRow extends StatelessWidget {
  final AssetHistoryItem item;
  final bool isStripe;
  final IconData icon;

  const _ReportRow({
    required this.item,
    required this.isStripe,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final actionType = _actionTypeFromString(item.action);
    return Container(
      padding: context.padSym(h: 16, v: 12),
      color: isStripe ? AppColors.reportRowStripeBg : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.subHeadingColor, size: 22),
          SizedBox(width: context.w(12)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.assetName,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(14),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.assetCode,
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(12),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.assetCode,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.employeeName,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(13),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: context.padSym(h: 10, v: 4),
              decoration: BoxDecoration(
                color: actionType.color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(context.radius(16)),
              ),
              child: Text(
                item.action.isNotEmpty ? item.action : actionType.label,
                style: TextStyle(
                  color: actionType.textColor,
                  fontSize: context.text(11),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.date,
              style: TextStyle(
                color: AppColors.subHeadingColor,
                fontSize: context.text(13),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
