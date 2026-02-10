import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../auth/otp_verify_screen.dart';
import '../addresses/address_list_screen.dart';
import '../security/pin_prompt.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final wallet = context.read<WalletProvider>();
    final auth = context.read<AuthProvider>();
    final address = context.read<AddressProvider>().defaultAddress;
    final orders = context.read<OrdersProvider>();

    if (cart.items.isEmpty) return;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a delivery address to continue.')),
      );
      Navigator.pushNamed(
        context,
        AppRouter.addresses,
        arguments: const AddressListArgs(selectionMode: true),
      );
      return;
    }

    if (!auth.isPhoneVerified) {
      final phone = (auth.currentUser?['phone'] as String?) ?? '';
      Navigator.pushNamed(
        context,
        AppRouter.otpVerify,
        arguments: OtpVerifyArgs(
          phone: phone,
          purposeLabel: 'Verify your phone to unlock your wallet',
          nextRouteName: AppRouter.checkout,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      if (wallet.balance < cart.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient wallet balance. Please top up.')),
        );
        return;
      }

      final pinOk = await PinPrompt.verify(
        context,
        reason: 'Confirm wallet payment (escrow hold) to place this order.',
      );
      if (!pinOk) return;
      if (!mounted) return;

      final order = orders.createFromCart(
            cartItems: cart.items,
            shopName: 'Local Storefront',
            deliveryFee: cart.deliveryFee,
          );

      await wallet.holdInEscrow(order.id, order.total);
      cart.clear();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.orderTracking,
        (r) => r.settings.name == AppRouter.home || r.isFirst,
        arguments: order.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final wallet = context.watch<WalletProvider>();
    final auth = context.watch<AuthProvider>();
    final address = context.watch<AddressProvider>().defaultAddress;

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Nothing to checkout yet.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.addresses,
              arguments: const AddressListArgs(selectionMode: true),
            ),
            borderRadius: BorderRadius.circular(18),
            child: _Card(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery address',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (address == null)
                          Text(
                            'Add an address',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFF59E0B),
                                  fontWeight: FontWeight.w700,
                                ),
                          )
                        else
                          Text(
                            [
                              address.addressText,
                              if ((address.city?.isNotEmpty ?? false) || (address.state?.isNotEmpty ?? false))
                                '${address.city ?? ''}${(address.city?.isNotEmpty ?? false) && (address.state?.isNotEmpty ?? false) ? ', ' : ''}${address.state ?? ''}',
                            ].where((e) => e.trim().isNotEmpty).join(' • '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SmartLink Wallet (Escrow)',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.isPhoneVerified
                                  ? 'Balance: ${Formatting.naira(wallet.balance, decimalDigits: 0)}'
                                  : 'Verify your phone to unlock wallet',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              children: [
                _Row(label: 'Subtotal', value: Formatting.naira(cart.subtotal, decimalDigits: 0)),
                const SizedBox(height: 8),
                _Row(
                  label: 'Delivery fee',
                  value: Formatting.naira(cart.deliveryFee, decimalDigits: 0),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _Row(
                  label: 'Total',
                  value: Formatting.naira(cart.total, decimalDigits: 0),
                  isStrong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Funds are held in escrow until you confirm delivery (or a timeout/dispute resolution).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            child: Text(_isPlacingOrder ? 'Placing order…' : 'Pay & place order'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isStrong;
  const _Row({required this.label, required this.value, this.isStrong = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: isStrong ? FontWeight.w900 : FontWeight.w700,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
