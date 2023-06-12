import 'package:flutter/material.dart';
import 'package:admin_side_app/group_view_widget.dart';

class MyGroup extends StatelessWidget {
  late String token;
  final List<dynamic> groups;
  final Function(String) updateToken;
  final bool adminView;
  MyGroup({required this.token, required this.groups, required this.updateToken, required this.adminView});

  void _updateToken(String newToken) {
    token = newToken;
    updateToken(newToken);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Groups'),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          final group = groups[index];
          final groupName = group['name'] as String;

          return Card(
            child: ListTile(
              title: Text(groupName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupView(
                      group: group,
                      token: token,
                      updateToken: _updateToken,
                      adminView: adminView,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
