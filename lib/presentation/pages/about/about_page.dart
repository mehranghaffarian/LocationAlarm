import 'package:flutter/material.dart';
import 'package:location_alarm/presentation/widgets/custom_app_bar.dart';
import 'package:location_alarm/presentation/widgets/custom_drawer.dart';

class AboutPage extends StatelessWidget {
  static const routeName = 'about_page';

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "This app helps you to get notified when you have arrived to your destination",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              "This app requires full access to your location(please check the settings)",
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
