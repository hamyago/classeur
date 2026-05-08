import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../shared/sidebar.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('transactions')
                          .orderBy('created_at', descending: true)
                          .snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snap.data!.docs;
                        double totalGross = 0, totalCommission = 0;
                        for (final d in docs) {
                          final data = d.data() as Map<String, dynamic>;
                          totalGross += (data['gross_amount'] as num?)?.toDouble() ?? 0;
                          totalCommission += (data['commission'] as num?)?.toDouble() ?? 0;
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Summary cards
                              Row(children: [
                                _SummaryCard(label: 'Chiffre d\'affaires total',
                                    value: _fcfa(totalGross), color: AdminColors.success),
                                const SizedBox(width: 16),
                                _SummaryCard(label: 'Commission Oyop MT (15%)',
                                    value: _fcfa(totalCommission), color: AdminColors.primary),
                                const SizedBox(width: 16),
                                _SummaryCard(label: 'Reversé aux prestataires',
                                    value: _fcfa(totalGross - totalCommission), color: AdminColors.warning),
                                const SizedBox(width: 16),
                                _SummaryCard(label: 'Nombre de transactions',
                                    value: '${docs.length}', color: AdminColors.textLight),
                              ]),
                              const SizedBox(height: 24),
                              // Table
                              Container(
                                decoration: BoxDecoration(
                                  color: AdminColors.sidebar,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AdminColors.border),
                                ),
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('INTERVENTION')),
                                    DataColumn(label: Text('BRUT')),
                                    DataColumn(label: Text('COMMISSION')),
                                    DataColumn(label: Text('NET PRESTATAIRE')),
                                    DataColumn(label: Text('PAIEMENT')),
                                    DataColumn(label: Text('DATE')),
                                  ],
                                  rows: docs.map((doc) {
                                    final d = doc.data() as Map<String, dynamic>;
                                    final ts = d['created_at'] as Timestamp?;
                                    return DataRow(cells: [
                                      DataCell(Text(
                                        (d['intervention_id'] as String? ?? '').substring(0, 8) + '...',
                                        style: const TextStyle(color: AdminColors.textMuted, fontSize: 12, fontFamily: 'monospace'),
                                      )),
                                      DataCell(Text(_fcfa((d['gross_amount'] as num?)?.toDouble() ?? 0),
                                          style: const TextStyle(color: AdminColors.textLight, fontWeight: FontWeight.w600))),
                                      DataCell(Text(_fcfa((d['commission'] as num?)?.toDouble() ?? 0),
                                          style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w600))),
                                      DataCell(Text(_fcfa((d['net_amount'] as num?)?.toDouble() ?? 0),
                                          style: const TextStyle(color: AdminColors.success, fontWeight: FontWeight.w600))),
                                      DataCell(Text(_paymentLabel(d['payment_method'] as String? ?? ''),
                                          style: const TextStyle(color: AdminColors.textMuted, fontSize: 12))),
                                      DataCell(Text(
                                          ts != null ? DateFormat('dd/MM/yy HH:mm').format(ts.toDate()) : '-',
                                          style: const TextStyle(color: AdminColors.textMuted, fontSize: 12))),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _header() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AdminColors.sidebar,
          border: Border(bottom: BorderSide(color: AdminColors.border)),
        ),
        child: const Row(children: [
          Text('Transactions & Revenus', style: TextStyle(color: AdminColors.textLight,
              fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
      );

  String _fcfa(double v) => '${NumberFormat('#,###', 'fr_FR').format(v.round())} FCFA';
  String _paymentLabel(String m) => switch (m) {
    'orange_money' => '🟠 Orange Money',
    'wave'         => '🔵 Wave',
    'card'         => '💳 Carte',
    _              => m,
  };
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminColors.sidebar,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
}
