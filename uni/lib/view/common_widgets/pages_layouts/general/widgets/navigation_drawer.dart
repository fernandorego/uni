import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni/generated/l10n.dart';
import 'package:uni/model/providers/startup/session_provider.dart';
import 'package:uni/utils/drawer_items.dart';
import 'package:uni/view/locale_notifier.dart';
import 'package:uni/view/theme_notifier.dart';

import '../../../../settings/settings.dart';

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({required this.parentContext, super.key});

  final BuildContext parentContext;

  @override
  State<StatefulWidget> createState() {
    return AppNavigationDrawerState();
  }
}

class AppNavigationDrawerState extends State<AppNavigationDrawer> {
  AppNavigationDrawerState();

  Map<DrawerItem, void Function(String)> drawerItems = {};

  @override
  void initState() {
    super.initState();

    drawerItems = {};
    for (final element in DrawerItem.values) {
      drawerItems[element] = _onSelectPage;
    }
  }

  String getCurrentRoute() =>
      ModalRoute.of(widget.parentContext)!.settings.name == null
          ? drawerItems.keys.toList()[0].title
          : ModalRoute.of(widget.parentContext)!.settings.name!.substring(1);

  void _onSelectPage(String key) {
    final prev = getCurrentRoute();

    Navigator.of(context).pop();

    if (prev != key) {
      Navigator.pushNamed(context, '/$key');
    }
  }

  void _onLogOut(String key) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/$key', (Route<dynamic> route) => false);
  }

  BoxDecoration? _getSelectionDecoration(String name) {
    return (name == getCurrentRoute())
        ? BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
            ),
            color: Theme.of(context).dividerColor,
          )
        : null;
  }

  Widget createLogoutBtn() {
    final logOutText = DrawerItem.navLogOut.title;
    return TextButton(
      onPressed: () => _onLogOut(logOutText),
      style: TextButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 5),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Text(
          S.of(context).logout,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget createDrawerNavigationOption(DrawerItem d) {
    return DecoratedBox(
      decoration: _getSelectionDecoration(d.title) ?? const BoxDecoration(),
      child: ListTile(
        title: Container(
          padding: const EdgeInsets.only(bottom: 3, left: 20),
          child: Text(
            S.of(context).nav_title(d.title),
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
        selected: d.title == getCurrentRoute(),
        onTap: () => drawerItems[d]!(d.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerOptions = <Widget>[];
    final userSession = context.read<SessionProvider>().session;

    for (final key in drawerItems.keys) {
      if (key.isVisible(userSession.faculties)) {
        drawerOptions.add(createDrawerNavigationOption(key));
      }
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 55),
              child: ListView(
                children: drawerOptions,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  child: createLogoutBtn(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<SettingsPage>(
                    builder: (_) => const SettingsPage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
