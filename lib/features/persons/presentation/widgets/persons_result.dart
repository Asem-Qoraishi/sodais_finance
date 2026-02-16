import 'package:flutter/material.dart';

class PersonsCountResult extends StatelessWidget {
  const PersonsCountResult({super.key, required this.resultCount});

  final int resultCount;
  @override
  Widget build(BuildContext context) {
    return Text("نتایج: $resultCount یافت شد");
  }
}
