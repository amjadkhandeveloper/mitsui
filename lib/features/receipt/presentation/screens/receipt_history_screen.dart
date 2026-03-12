import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../cubit/receipt_cubit.dart';
import '../widgets/summary_card.dart';
import '../widgets/receipt_list_item.dart';
import 'receipt_detail_screen.dart';
import '../../domain/entities/receipt.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../../core/di/injection_container.dart' as di;

class ReceiptHistoryScreen extends StatefulWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  State<ReceiptHistoryScreen> createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen> {
  UserRole? _role;
  int? _approvedByUserId;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.getCurrentUser();
    User? user;
    result.fold((_) => null, (u) => user = u);
    if (user == null) return;

    final localStorage = di.sl<LocalStorageDataSource>();
    final uid = await localStorage.getUserId();

    if (mounted) {
      setState(() {
        _role = user!.role;
        _approvedByUserId = int.tryParse(uid ?? '');
      });
    }

    String? driverId;
    String? userId;
    final storedDriverId = await localStorage.getDriverId();

    if (user!.role == UserRole.driver) {
      driverId = (storedDriverId != null && storedDriverId.isNotEmpty)
          ? storedDriverId
          : user!.id;
      userId = '0';
    } else {
      driverId = '0';
      userId = (uid != null && uid.isNotEmpty) ? uid : user!.id;
    }

    if (!mounted) return;
    context.read<ReceiptCubit>().loadReceipts(
          driverId: driverId,
          userId: userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Receipt History'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadReceipts();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptError) {
            Toast.showError(context, state.message);
          } else if (state is ReceiptCreated) {
            Toast.showSuccess(context, 'Receipt submitted successfully');
          } else if (state is ReceiptStatusUpdated) {
            Toast.showSuccess(context, 'Status updated successfully');
          }
        },
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceiptsLoaded) {
            return Column(
              children: [
                // Summary Cards - Horizontal Scrollable
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: SummaryCard(
                            icon: Icons.receipt_long,
                            iconColor: Colors.blue,
                            value: '${state.total}',
                            label: 'Total',
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: SummaryCard(
                            icon: Icons.check_circle,
                            iconColor: Colors.green,
                            value: '${state.approved}',
                            label: 'Approved',
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: SummaryCard(
                            icon: Icons.access_time,
                            iconColor: Colors.orange,
                            value: '${state.pending}',
                            label: 'Pending',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Receipt List
                Expanded(
                  child: state.receipts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No receipts found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await _loadReceipts();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: state.receipts.length,
                            itemBuilder: (context, index) {
                              final receipt = state.receipts[index];
                              final expenseId = receipt.expenseId ??
                                  int.tryParse(receipt.id);
                              final expenseTypeId = receipt.expenseTypeId;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptDetailScreen(
                                        receipt: receipt,
                                      ),
                                    ),
                                  );
                                },
                                child: ReceiptListItem(
                                      receipt: receipt,
                                      index: index,
                                      showApprovalActions: _role == UserRole.expat &&
                                          receipt.type != ReceiptType.fuel,
                                  onApprove: (_role == UserRole.expat &&
                                              receipt.type != ReceiptType.fuel &&
                                          expenseId != null &&
                                          _approvedByUserId != null)
                                      ? () async {
                                          final remark = await _showApproveRemarkDialog(context);
                                          if (remark == null || remark.trim().isEmpty) return;
                                          context.read<ReceiptCubit>().approveReceipt(
                                                expenseId: expenseId,
                                                expenseTypeId: expenseTypeId,
                                                approvedByUserId: _approvedByUserId!,
                                                remark: remark.trim(),
                                              );
                                        }
                                      : null,
                                  onReject: (_role == UserRole.expat &&
                                              receipt.type != ReceiptType.fuel &&
                                          expenseId != null &&
                                          _approvedByUserId != null)
                                      ? () async {
                                          final remark = await _showRejectRemarkDialog(context);
                                          if (remark == null || remark.trim().isEmpty) return;
                                          context.read<ReceiptCubit>().rejectReceipt(
                                                expenseId: expenseId,
                                                expenseTypeId: expenseTypeId,
                                                approvedByUserId: _approvedByUserId!,
                                                remark: remark.trim(),
                                              );
                                        }
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
      floatingActionButton: _role == UserRole.driver
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addReceipt);
              },
              backgroundColor: AppTheme.mitsuiDarkBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Future<String?> _showRejectRemarkDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Receipt'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Remark *',
              hintText: 'Enter rejection remark',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showApproveRemarkDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Approve Receipt'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Remark *',
              hintText: 'Enter approval remark',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

