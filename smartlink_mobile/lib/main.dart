import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/zone_provider.dart';
import 'providers/address_provider.dart';
import 'providers/kyc_provider.dart';
import 'providers/services_provider.dart';
import 'providers/service_requests_provider.dart';
import 'providers/security_provider.dart';
import 'providers/feed_provider.dart';

void main() {
  runApp(const SmartLinkApp());
}

class SmartLinkApp extends StatelessWidget {
  const SmartLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ZoneProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => KycProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRequestsProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SmartLink',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.splash,
          );
        },
      ),
    );
  }
}
