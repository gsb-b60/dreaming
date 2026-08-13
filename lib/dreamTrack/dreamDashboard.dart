import 'package:dreaming/dreamTrack/dreamScreen.dart';
import 'package:flutter/material.dart';

class DreamDashBoard extends StatefulWidget {
  const DreamDashBoard({super.key});

  @override
  State<DreamDashBoard> createState() => _DreamDashBoardState();
}

class _DreamDashBoardState extends State<DreamDashBoard> {
  @override
  Widget build(BuildContext context) {
    return  Placeholder(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Dream Dashboard'),
              SizedBox(height: 20),
              Text('This is a placeholder for the Dream Dashboard.'),
              Text('this is the dashboard for the dream tracking app.'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dreamscreen()),
                  );
                },
                child: Text('this is the list of dreams that the user has recorded.'),
              ),
            ],
          ),
        ),
      )
    );
  }
}