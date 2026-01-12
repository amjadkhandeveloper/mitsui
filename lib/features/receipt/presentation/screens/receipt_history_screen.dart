import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../cubit/receipt_cubit.dart';
import '../widgets/summary_card.dart';
import '../widgets/receipt_list_item.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../../core/di/injection_container.dart' as di;

class ReceiptHistoryScreen extends StatefulWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  State<ReceiptHistoryScreen> createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => null,
      (user) {
        final driverId = user?.role == UserRole.driver ? user?.id : null;
        context.read<ReceiptCubit>().loadReceipts(
              driverId: driverId,
              status: selectedStatus,
            );
      },
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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('All'),
                        onTap: () {
                          setState(() {
                            selectedStatus = null;
                          });
                          Navigator.pop(context);
                          _loadReceipts();
                        },
                      ),
                      ListTile(
                        title: const Text('Approved'),
                        onTap: () {
                          setState(() {
                            selectedStatus = 'approved';
                          });
                          Navigator.pop(context);
                          _loadReceipts();
                        },
                      ),
                      ListTile(
                        title: const Text('Pending'),
                        onTap: () {
                          setState(() {
                            selectedStatus = 'pending';
                          });
                          Navigator.pop(context);
                          _loadReceipts();
                        },
                      ),
                      ListTile(
                        title: const Text('Rejected'),
                        onTap: () {
                          setState(() {
                            selectedStatus = 'rejected';
                          });
                          Navigator.pop(context);
                          _loadReceipts();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptError) {
            Toast.showError(context, state.message);
          } else if (state is ReceiptCreated) {
            Toast.showSuccess(context, 'Receipt submitted successfully');
          }
        },
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceiptsLoaded) {
            return Column(
              children: [
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SummaryCard(
                        icon: Icons.receipt_long,
                        iconColor: Colors.blue,
                        value: '${state.total} Total',
                        label: 'Total',
                      ),
                      SummaryCard(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        value: '${state.approved} Approved',
                        label: 'Approved',
                      ),
                      SummaryCard(
                        icon: Icons.access_time,
                        iconColor: Colors.orange,
                        value: '${state.pending} Pending',
                        label: 'Pending',
                      ),
                    ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.receipts.length,
                            itemBuilder: (context, index) {
                              return ReceiptListItem(
                                receipt: state.receipts[index],
                                index: index,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addReceipt);
        },
        backgroundColor: AppTheme.mitsuiDarkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

