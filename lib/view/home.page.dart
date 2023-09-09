import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Deliveries',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text('User Menu'),
                decoration: BoxDecoration(
                  color: Color(0xFFBD2019),
                ),
              ),
              ListTile(
                title: const Text('Logout'),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCB8686),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabs: [
                    Container(
                      height: 30,
                      width: 90.0,
                      child: const Tab(
                        child: Text(
                          'Pending',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 90.0,
                      child: const Tab(
                        child: Text(
                          'Completed',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 90.0,
                      child: const Tab(
                        child: Text(
                          'Failed',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                  indicator: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: const Color(0xFFBD2019),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Pending Content')),
                  Center(child: Text('Completed Content')),
                  Center(child: Text('Failed Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
