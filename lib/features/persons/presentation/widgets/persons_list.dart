// lib/features/persons/presentation/widgets/persons_list.dart
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/person_card.dart';

class PersonsList extends StatelessWidget {
  final List<Person> persons;
  const PersonsList({super.key, required this.persons});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: sizeConstants.spacingXXLarge),
      itemCount: persons.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: sizeConstants.spacingXSmall),
      itemBuilder: (context, index) => PersonCard(person: persons[index]),
    );
  }
}
