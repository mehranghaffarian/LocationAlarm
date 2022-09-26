import 'package:flutter/material.dart';
import 'package:location_alarm/presentation/pages/about/about_page.dart';
import 'package:location_alarm/presentation/pages/history/history.dart';
import 'package:location_alarm/presentation/pages/home_page/home_page.dart';
import 'package:location_alarm/presentation/pages/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrawerOption(
              onTap: () => Navigator.of(context).pushNamed(HomePage.routeName),
              title: "Home",
              theme: theme,
              iconShape: Icons.home_sharp,
            ),
            Divider(
              color: theme.backgroundColor,
              thickness: 1,
            ),
            _buildDrawerOption(
              iconShape: Icons.history_sharp,
              theme: theme,
              onTap: () => Navigator.of(context).pushNamed(History.routeName),
              title: 'History',
            ),
            Divider(
              color: theme.backgroundColor,
              thickness: 1,
            ),
            _buildDrawerOption(
              theme: theme,
              onTap: () => Navigator.of(context).pushNamed(Settings.routeName),
              title: 'Settings',
              iconShape: Icons.settings_sharp,
            ),
            Divider(
              color: theme.backgroundColor,
              thickness: 1,
            ),
            _buildDrawerOption(
              theme: theme,
              onTap: () => Navigator.of(context).pushNamed(AboutPage.routeName),
              title: 'About',
              iconShape: Icons.info_sharp,
            ),
            Divider(
              color: theme.backgroundColor,
              thickness: 1,
            ),
            _buildDrawerOption(
              theme: theme,
              onTap: () => launchUrl(
                Uri.parse('https://www.buymeacoffee.com/MG81'),
                mode: LaunchMode.inAppWebView,
              ),
              title: 'Buy me a Coffee',
              iconShape: Icons.coffee_sharp,
            ),
            Divider(
              color: theme.backgroundColor,
              thickness: 1,
            ),
            _buildDrawerOption(
              theme: theme,
              onTap: () => launchUrl(
                Uri.parse('https://www.coffeete.ir/MG81'),
                mode: LaunchMode.inAppWebView,
              ),
              title: 'Buy me a Coffeete',
              iconShape: Icons.coffee_maker_sharp,
            ),
          ],
        ),
      ),
    );
  }

  _buildDrawerOption({
    required ThemeData theme,
    required String title,
    required IconData iconShape,
    required Function onTap,
  }) =>
      InkWell(
        onTap: () => onTap(),
        child: SizedBox(
          height: 45,
          child: Row(
            children: [
              Icon(
                iconShape,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
}
