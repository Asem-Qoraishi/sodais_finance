import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';

class PersonsSearchField extends ConsumerStatefulWidget {
  const PersonsSearchField({super.key});

  @override
  ConsumerState<PersonsSearchField> createState() => _PersonsSearchFieldState();
}

class _PersonsSearchFieldState extends ConsumerState<PersonsSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(personSearchQueryProvider);

    if (_controller.text != query) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return CustomTextField(
      controller: _controller,
      onChange: (val) =>
          ref.read(personSearchQueryProvider.notifier).update(val),
      hintText: LocaleKeys.search_persons.tr(),
      prefixIconSource: Assets.icons.search,
      suffixIcon: query.trim().isEmpty
          ? null
          : IconButton(
              onPressed: () {
                _controller.clear();
                ref.read(personSearchQueryProvider.notifier).update('');
              },
              icon: const Icon(Icons.clear_rounded, size: 20),
            ),
    );
  }
}
