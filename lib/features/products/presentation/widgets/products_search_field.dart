import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';

class InventorySearchField extends ConsumerWidget {
  const InventorySearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomTextField(
      // onChanged: ref.read(personsControllerProvider.notifier).search,
      hintText: LocaleKeys.search_products.tr(),
      prefixIconSource: Assets.icons.search,
    );
  }
}
