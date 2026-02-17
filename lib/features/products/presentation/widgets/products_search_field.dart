import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';

class InventorySearchField extends ConsumerStatefulWidget {
  const InventorySearchField({super.key});

  @override
  ConsumerState<InventorySearchField> createState() =>
      _InventorySearchFieldState();
}

class _InventorySearchFieldState extends ConsumerState<InventorySearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(productSearchQueryProvider);

    if (_controller.text != query) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return CustomTextField(
      controller: _controller,
      onChange: (value) =>
          ref.read(productSearchQueryProvider.notifier).update(value),
      hintText: LocaleKeys.search_products.tr(),
      prefixIconSource: Assets.icons.search,
      suffixIcon: query.trim().isEmpty
          ? null
          : IconButton(
              onPressed: () {
                _controller.clear();
                ref.read(productSearchQueryProvider.notifier).update('');
              },
              icon: const Icon(Icons.clear_rounded, size: 20),
            ),
    );
  }
}
