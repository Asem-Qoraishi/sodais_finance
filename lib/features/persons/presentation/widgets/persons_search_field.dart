import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';

class PersonsSearchField extends ConsumerWidget {
  const PersonsSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizeConstants.spacingMedium),
      child: CustomTextField(
        onChange: (val) =>
            ref.read(personSearchQueryProvider.notifier).update(val),
        hintText: LocaleKeys.search_persons.tr(),
        prefixIconSource: Assets.icons.search,
        // Add a clear button for better UX
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_rounded, size: 20),
          onPressed: () =>
              ref.read(personSearchQueryProvider.notifier).update(''),
        ),
      ),
    );
  }
}
