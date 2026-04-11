import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../screens/availability/availability_lookup_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/employees/employee_form_screen.dart';
import '../screens/employees/employee_list_screen.dart';
import '../screens/employees/employee_profile_screen.dart';
import '../screens/employees/shift_log_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/event_form_screen.dart';
import '../screens/events/event_list_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return _ShellScaffold(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/employees',
              name: 'employees',
              builder: (BuildContext context, GoRouterState state) {
                return const EmployeeListScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'add',
                  name: 'employees-add',
                  builder: (BuildContext context, GoRouterState state) {
                    return const EmployeeFormScreen();
                  },
                ),
                GoRoute(
                  path: ':id',
                  name: 'employees-detail',
                  builder: (BuildContext context, GoRouterState state) {
                    return EmployeeProfileScreen(
                      employeeId: state.pathParameters['id'] ?? '',
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'edit',
                      name: 'employees-edit',
                      builder: (BuildContext context, GoRouterState state) {
                        return EmployeeFormScreen(
                          employeeId: state.pathParameters['id'],
                        );
                      },
                    ),
                    GoRoute(
                      path: 'shifts',
                      name: 'employees-shifts',
                      builder: (BuildContext context, GoRouterState state) {
                        return ShiftLogScreen.forEmployee(
                          employeeId: state.pathParameters['id'] ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/events',
              name: 'events',
              builder: (BuildContext context, GoRouterState state) {
                return const EventListScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'add',
                  name: 'events-add',
                  builder: (BuildContext context, GoRouterState state) {
                    final String? dateParam = state.uri.queryParameters['date'];
                    final DateTime? prefilledDate =
                        dateParam == null ? null : DateTime.tryParse(dateParam);
                    return EventFormScreen(initialDate: prefilledDate);
                  },
                ),
                GoRoute(
                  path: ':id',
                  name: 'events-detail',
                  builder: (BuildContext context, GoRouterState state) {
                    return EventDetailScreen(
                      eventId: state.pathParameters['id'] ?? '',
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'edit',
                      name: 'events-edit',
                      builder: (BuildContext context, GoRouterState state) {
                        return EventFormScreen(
                          eventId: state.pathParameters['id'],
                        );
                      },
                    ),
                    GoRoute(
                      path: 'shift-logs',
                      name: 'events-shift-logs',
                      builder: (BuildContext context, GoRouterState state) {
                        return ShiftLogScreen.forEvent(
                          eventId: state.pathParameters['id'] ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/calendar',
              name: 'calendar',
              builder: (BuildContext context, GoRouterState state) {
                return const CalendarScreen();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/availability',
      name: 'availability',
      builder: (BuildContext context, GoRouterState state) {
        return const AvailabilityLookupScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
    ),
  ],
);

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.group_outlined),
            selectedIcon: const Icon(Icons.group),
            label: l10n.navEmployees,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: l10n.navEvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
        ],
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

