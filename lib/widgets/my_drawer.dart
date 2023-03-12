import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        DrawerHeader(
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.4, color: Colors.grey))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 35,
                child: Icon(Icons.account_box_rounded),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Jason',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const ListTile(
          leading: Icon(Icons.pedal_bike),
          dense: true,
          title: Text('Ride History'),
        ),
        const ListTile(
          leading: Icon(Icons.card_giftcard),
          dense: true,
          title: Text('Refer Friend'),
        ),
        const ListTile(
          leading: Icon(Icons.credit_card),
          dense: true,
          title: Text('Payment'),
        ),
        const ListTile(
          leading: Icon(Icons.bubble_chart),
          dense: true,
          title: Text('Rewards'),
        ),
        const ListTile(
          leading: Icon(Icons.chat_bubble_outline),
          dense: true,
          title: Text('Help'),
        ),
        const ListTile(
          leading: Icon(Icons.settings),
          dense: true,
          title: Text('Settings'),
        ),
      ]),
    );
  }
}
