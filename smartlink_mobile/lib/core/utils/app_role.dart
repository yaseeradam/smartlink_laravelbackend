enum AppRole {
  customer,
  merchant,
  rider,
}

extension AppRoleX on AppRole {
  String get apiValue => switch (this) {
        AppRole.customer => 'buyer',
        AppRole.merchant => 'seller',
        AppRole.rider => 'rider',
      };

  String get label => switch (this) {
        AppRole.customer => 'Customer',
        AppRole.merchant => 'Merchant',
        AppRole.rider => 'Pilot',
      };

  String get subtitle => switch (this) {
        AppRole.customer => 'Shop with protected payments',
        AppRole.merchant => 'Sell locally with trust',
        AppRole.rider => 'Deliver & earn',
      };

  static AppRole fromApiValue(String? value) {
    switch ((value ?? '').toLowerCase().trim()) {
      case 'seller':
      case 'merchant':
        return AppRole.merchant;
      case 'rider':
      case 'pilot':
        return AppRole.rider;
      case 'buyer':
      case 'customer':
      default:
        return AppRole.customer;
    }
  }
}

