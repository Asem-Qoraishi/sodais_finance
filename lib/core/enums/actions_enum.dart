import 'package:flutter/material.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';

enum ActionsEnum {
  buy,
  sell,
  rented,
  retruned,
  payment;

  String get iconSource => switch (this) {
    buy => Assets.icons.buyProducts,
    ActionsEnum.sell => Assets.icons.sellProducts,
    ActionsEnum.rented => Assets.icons.delivery,
    ActionsEnum.retruned => Assets.icons.returnProducts,
    ActionsEnum.payment => Assets.icons.payment,
  };

  Color get iconColor => switch (this) {
    buy => Colors.green,
    ActionsEnum.sell => Colors.red,
    ActionsEnum.rented => Colors.green,
    ActionsEnum.retruned => Colors.red,
    ActionsEnum.payment => Colors.green,
  };
}
