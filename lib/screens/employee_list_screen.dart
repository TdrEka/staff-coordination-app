import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/reliability_badge.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  static const List<_EmployeeRow> _active = <_EmployeeRow>[
    _EmployeeRow('Lucia Perez', <String>['Camarera', 'Coordinadora'], 8.4),
    _EmployeeRow('Carlos Mena', <String>['Bartender', 'Runner'], 6.7),
  ];

  static const List<_EmployeeRow> _archive = <_EmployeeRow>[];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Ordenar',
              onPressed: () {},
              icon: const Icon(Icons.sort, color: AppTheme.primary),
            ),
          ],
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Activos'),
              Tab(text: 'Archivo'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _EmployeeTab(rows: _active),
            _EmployeeTab(rows: _archive),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('+ Anadir persona'),
        ),
      ),
    );
  }
}

class _EmployeeTab extends StatelessWidget {
  const _EmployeeTab({required this.rows});

  final List<_EmployeeRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.group_off_outlined, size: 56, color: AppTheme.secondary),
              const SizedBox(height: AppSpacing.sm),
              Text('Sin personas en esta vista', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 88),
      itemCount: rows.length,
      itemBuilder: (BuildContext context, int index) {
        final _EmployeeRow row = rows[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _initials(row.name),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(row.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: row.roles
                            .map(
                              (String role) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(role, style: Theme.of(context).textTheme.labelSmall),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                ReliabilityBadge(score: row.score),
                const SizedBox(width: AppSpacing.xs),
                IconButton(onPressed: () {}, icon: const Icon(Icons.phone_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chat_outlined)),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _initials(String name) {
    final List<String> parts = name.split(' ');
    if (parts.length < 2) {
      return name.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _EmployeeRow {
  const _EmployeeRow(this.name, this.roles, this.score);

  final String name;
  final List<String> roles;
  final double score;
}

