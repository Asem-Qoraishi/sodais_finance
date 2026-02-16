import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/widgets/texts/result_count.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/person_app_bar.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_filter_bar.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_list.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_order_by.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/persons_search_field.dart';

class PersonsScreen extends ConsumerWidget {
  const PersonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsControllerProvider);

    return Scaffold(
      appBar: const PersonsAppBar(),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: Column(
          spacing: sizeConstants.spacingSmall,
          children: [
            const PersonsSearchField(),
            const PersonsFilterBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResultCount(resultCount: personsAsync.value?.length ?? 0),
                PersonsOrderBy(),
              ],
            ),
            Expanded(
              child: personsAsync.when(
                data: (persons) => PersonsList(persons: persons),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => const Center(
                  child: Text('Failed to load persons'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
