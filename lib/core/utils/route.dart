import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_accounting_system/main_menu_screen.dart';

class NameRouters {
  String khomeScreen = '/';
  String kInvoiceDetailsScreen = '/invoice_details_screen';
  String kCustomerReminderScreen = '/customer_reminder_screen';
}

abstract class AppRouter {
  static const khomeScreen = '/';
  static NameRouters nameRouters = NameRouters();
  static final router = GoRouter(
    routes: [
      // Name Routes
      GoRoute(
        path: AppRouter.nameRouters.khomeScreen,
        builder: (context, state) => const MainMenuScreen(),
      ),

      // GoRoute(
      //   path: AppRouter.nameRouters.kInvoiceDetailsScreen,
      //   builder: (context, state) {
      //     final List<dynamic> args = state.extra as List<dynamic>;
      //     final int id = args[0];
      //     final String isDefaultType = args[1];
      //     return InvoiceDetailsScreen(id: id, isDefaultType: isDefaultType);
      //   },
      // ),

      // GoRoute(
      //   path: AppRouter.nameRouters.kCustomerReminderScreen,
      //   builder: (context, state) {
      //     final List<dynamic> args = state.extra as List<dynamic>;
      //     final int id = args[0];
      //     final String isDefaultType = args[1];

      //     return CustomerReminderScreen(id: id, isDefaultType: isDefaultType);
      //   },
      // ),
    ],
  );
}
