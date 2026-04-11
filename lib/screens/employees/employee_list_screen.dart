import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/employee.dart';
import '../../models/enums.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/employee_card.dart';

enum EmployeeSort {
  name,
  reliability,
  role,
}

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  EmployeeSort _sort = EmployeeSort.name;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Employee> employees = ref.watch(employeesProvider);

    final List<Employee> activeEmployees = employees
        .where((Employee e) => e.status == EmployeeStatus.active)
        .toList();
    final List<Employee> inactiveEmployees = employees
        .where((Employee e) => e.status == EmployeeStatus.inactive)
        .toList();

    _sortEmployees(activeEmployees);
    _sortEmployees(inactiveEmployees);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.employeesTitle),
          actions: <Widget>[
            PopupMenuButton<EmployeeSort>(
              tooltip: 'Ordenar personal',
              onSelected: (EmployeeSort value) {
                setState(() {
                  _sort = value;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<EmployeeSort>>[
                PopupMenuItem<EmployeeSort>(
                  value: EmployeeSort.name,
                  child: const Text('Nombre'),
                ),
                PopupMenuItem<EmployeeSort>(
                  value: EmployeeSort.reliability,
                  child: const Text('Fiabilidad'),
                ),
                PopupMenuItem<EmployeeSort>(
                  value: EmployeeSort.role,
                  child: Text(l10n.slotRole),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceVariant,
            labelStyle: Theme.of(context).textTheme.labelLarge,
            tabs: <Tab>[
              Tab(text: l10n.employeesActive),
              Tab(text: l10n.employeesInactive),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _buildEmployeeList(
              context,
              activeEmployees,
              emptyTitle: l10n.employeesEmpty,
              emptyActionLabel: l10n.employeesAdd,
              emptyAction: () => context.go('/employees/add'),
            ),
            _buildEmployeeList(
              context,
              inactiveEmployees,
              emptyTitle: 'No hay personal archivado',
              inactive: true,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/employees/add'),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('Añadir persona'),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(
    BuildContext context,
    List<Employee> employees, {
    required String emptyTitle,
    String? emptyActionLabel,
    VoidCallback? emptyAction,
    bool inactive = false,
  }) {
    if (employees.isEmpty) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      if (emptyActionLabel != null && emptyAction != null) {
        return EmptyStatePanel(
          title: emptyTitle,
          subtitle: 'Añade personal para empezar a gestionar turnos.',
          actionLabel: emptyActionLabel,
          icon: Icons.group_outlined,
          onAction: emptyAction,
        );
      }

      return EmptyStatePanel(
        title: emptyTitle,
        subtitle: 'Las personas desactivadas aparecerán aquí.',
        actionLabel: l10n.employeesAdd,
        icon: Icons.archive_outlined,
        onAction: () => context.go('/employees/add'),
      );
    }

    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (BuildContext context, int index) {
        final Employee employee = employees[index];
        return EmployeeCard(
          employee: employee,
          onTap: () => context.go('/employees/${employee.id}'),
          trailing: inactive
              ? SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.employeesReactivate,
                    onPressed: () {
                      ref.read(employeesProvider.notifier).reactivate(employee.id);
                    },
                    icon: const Icon(Icons.restore_from_trash),
                  ),
                )
              : null,
        );
      },
    );
  }

  void _sortEmployees(List<Employee> employees) {
    switch (_sort) {
      case EmployeeSort.name:
        employees.sort((Employee a, Employee b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case EmployeeSort.reliability:
        employees.sort((Employee a, Employee b) => b.reliabilityScore.compareTo(a.reliabilityScore));
        break;
      case EmployeeSort.role:
        employees.sort((Employee a, Employee b) {
          final String roleA = a.roles.isEmpty ? '' : a.roles.first.toLowerCase();
          final String roleB = b.roles.isEmpty ? '' : b.roles.first.toLowerCase();
          return roleA.compareTo(roleB);
        });
        break;
    }
  }
}
