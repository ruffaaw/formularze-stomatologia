import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Gabinet Ortodontyczny Agnieszka Golarz-Nosek",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "31-542 Kraków , ul. Kordylewskiego 1/3",
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
          Text(
            "tel. 12 22 67 01, 601-949-752, e-mail: gabinet@golarz.pl",
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
