import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/person_card.dart';

class PersonsList extends ConsumerWidget {
  const PersonsList({super.key, required this.persons});

  final List<Person> persons;

  Future<void> _openActions(
    BuildContext context,
    WidgetRef ref,
    Person person,
  ) async {
    final selected = await showModalBottomSheet<_PersonAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(LocaleKeys.editPerson.tr()),
              onTap: () => Navigator.of(context).pop(_PersonAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(LocaleKeys.transactionsList.tr()),
              onTap: () =>
                  Navigator.of(context).pop(_PersonAction.transactions),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(LocaleKeys.delete.tr()),
              onTap: () => Navigator.of(context).pop(_PersonAction.delete),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || selected == null) return;

    switch (selected) {
      case _PersonAction.edit:
        context.pushNamed(routeNames.editPerson, extra: person);
        return;
      case _PersonAction.transactions:
        context.pushNamed(routeNames.personTransactions, extra: person);
        return;
      case _PersonAction.delete:
        final shouldDelete = await showDeleteConfirmationDialog(
          context: context,
          title: LocaleKeys.delete.tr(),
          message: LocaleKeys.deletePersonConfirmation.tr(
            namedArgs: {'name': person.name},
          ),
        );

        if (!shouldDelete) return;
        await ref
            .read(personsControllerProvider.notifier)
            .deletePerson(person.id);
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: sizeConstants.spacingXXLarge),
      itemCount: persons.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: sizeConstants.spacingXSmall),
      itemBuilder: (context, index) => PersonCard(
        person: persons[index],
        onTap: () => _openActions(context, ref, persons[index]),
      ),
    );
  }
}

enum _PersonAction { edit, transactions, delete }
