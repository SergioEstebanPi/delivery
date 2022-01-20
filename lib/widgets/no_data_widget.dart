import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String text;

  const NoDataWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 60),
      child: Column(
        children: [
          Image.asset('assets/img/no_items.png'),
          Text(
            text
          )
        ],
      ),
    );
  }
}
