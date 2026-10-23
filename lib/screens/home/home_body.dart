import 'package:flutter/material.dart';

class HomeBody extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          color: Colors.red,
          child: const Center(child: Text('Home')),
        ),
      ],
    );
  }
}
