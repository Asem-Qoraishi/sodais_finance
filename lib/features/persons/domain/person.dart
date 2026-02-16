import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum PersonType {
  customer('customer'),
  supplier('supplier'),
  both('both');

  const PersonType(this.value);

  final String value;

  static PersonType fromValue(String? value) {
    return PersonType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PersonType.customer,
    );
  }

  String get label {
    switch (this) {
      case PersonType.customer:
        return LocaleKeys.customer.tr();
      case PersonType.supplier:
        return LocaleKeys.supplier.tr();
      case PersonType.both:
        return LocaleKeys.both.tr();
    }
  }
}

enum BalanceStatus {
  credit,
  debt,
  settled;

  String get name {
    switch (this) {
      case BalanceStatus.credit:
        return LocaleKeys.credit.tr();
      case BalanceStatus.debt:
        return LocaleKeys.debt.tr();
      case BalanceStatus.settled:
        return LocaleKeys.settled.tr();
    }
  }

  Color get color {
    switch (this) {
      case BalanceStatus.credit:
        return Colors.green;
      case BalanceStatus.debt:
        return Colors.red;
      case BalanceStatus.settled:
        return Colors.grey;
    }
  }
}

class Person {
  final String id;
  final String? image;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final PersonType type;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Person({
    required this.id,
    this.image,
    required this.name,
    this.phone,
    this.address,
    this.email,
    required this.type,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  BalanceStatus get balanceStatus {
    if (balance > 0) return BalanceStatus.credit;
    if (balance < 0) return BalanceStatus.debt;
    return BalanceStatus.settled;
  }
}
