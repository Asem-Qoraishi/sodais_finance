import 'package:flutter/material.dart';

class ResultCount extends StatelessWidget {
  const ResultCount({super.key, required this.resultCount});

  final int resultCount;
  @override
  Widget build(BuildContext context) {
    return Text("نتایج: $resultCount یافت شد");
  }
}
