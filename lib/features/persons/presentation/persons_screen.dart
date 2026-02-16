import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/person_app_bar.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_filter_bar.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_list.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_order_by.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_search_field.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_summary_cards.dart';

class PersonsScreen extends ConsumerWidget {
  const PersonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsControllerProvider);
    final persons = personsAsync.asData?.value ?? const <Person>[];

    return Scaffold(
      appBar: const PersonsAppBar(),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PersonsSearchField(),
            SizedBox(height: sizeConstants.spacingSmall),
            const PersonsFilterBar(),
            SizedBox(height: sizeConstants.spacingSmall),
            PersonsSummaryCards(persons: persons),
            SizedBox(height: sizeConstants.spacingSmall),
            const PersonsOrderBy(),
            SizedBox(height: sizeConstants.spacingXSmall),
            Expanded(
              child: personsAsync.when(
                data: (persons) {
                  if (persons.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKeys.noPersonsFound.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return PersonsList(persons: persons);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    LocaleKeys.failedToLoadPersons.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
