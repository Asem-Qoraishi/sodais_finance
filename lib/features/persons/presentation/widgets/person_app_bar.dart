import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

class PersonsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PersonsAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(LocaleKeys.persons.tr()),
      actions: [
        IconButton(
          onPressed: () => context.pushNamed(routeNames.addNewPerson),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          tooltip: LocaleKeys.addNewPerson.tr(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
