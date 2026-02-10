import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';
import 'customer_home_screen.dart';
import 'merchant_home_screen.dart';
import 'rider_home_screen.dart';

class HomeGateScreen extends StatelessWidget {
  const HomeGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    switch (role) {
      case AppRole.customer:
        return const CustomerHomeScreen();
      case AppRole.merchant:
        return const MerchantHomeScreen();
      case AppRole.rider:
        return const RiderHomeScreen();
    }
  }
}

