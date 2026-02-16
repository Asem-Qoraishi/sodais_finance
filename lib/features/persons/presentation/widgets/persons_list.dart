// lib/features/persons/presentation/widgets/persons_list.dart
import 'package:flutter/material.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/widgets/person_card.dart';

class PersonsList extends StatelessWidget {
  final List<Person> persons;
  const PersonsList({super.key, required this.persons});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: persons.length,
      itemBuilder: (_, i) => PersonCard(person: persons[i]),
    );
  }
}
