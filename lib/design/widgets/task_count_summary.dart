import 'package:flutter/material.dart';

class TaskCountSummaryCard extends StatelessWidget {
  const TaskCountSummaryCard({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),

      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Icon(
                      Icons.check_circle,
                      size: 25.0,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    width: 0,
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black
                    )
                    ,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Text('$count', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
