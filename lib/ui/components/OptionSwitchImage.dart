import 'dart:async';

import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:thepublictransport_app/framework/theme/ThemeEngine.dart';

class OptionSwitchImage extends StatefulWidget {
  OptionSwitchImage(
      {@required this.title, @required this.icon, @required this.id, this.default_bool, this.subtitle});

  final String title;
  final String subtitle;
  final String icon;
  final String id;
  final bool default_bool;

  @override
  _OptionSwitchImageState createState() =>
      _OptionSwitchImageState(this.title, this.icon, this.id, this.default_bool, this.subtitle);
}

class _OptionSwitchImageState extends State<OptionSwitchImage> {
  _OptionSwitchImageState(this.title, this.icon, this.id, this.default_bool, this.subtitle) {
    if (this.default_bool != null) {
      if (PrefService.getBool(id) == null) {
        PrefService.setBool(id, this.default_bool);
      }
    }
  }

  final String title;
  final String subtitle;
  final String icon;
  final String id;
  final bool default_bool;

  bool isSwitched = false;

  var theme = ThemeEngine.getCurrentTheme();

  Future<bool> getSwitched() async {
    if (PrefService.getBool(id) != null)
      return PrefService.getBool(id);
    else
      return false;
  }

  setSwitched(value) async {
    PrefService.setBool(id, value);
  }

  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Image(
        image: AssetImage(
            icon
        ),
      ),
      title: new Text(
        this.title,
        style: TextStyle(
            color: theme.textColor,
            fontFamily: "NunitoSansBold"
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: theme.subtitleColor)) : null,
      trailing: Switch(
        value: PrefService.getBool(id),
        onChanged: (value) {
          setState(() {
            setSwitched(value);
          });
        },
        activeTrackColor: theme.iconColor.withAlpha(90),
        activeColor: theme.iconColor,
        inactiveTrackColor: Colors.grey[200],
        inactiveThumbColor: Colors.grey[300],
      ),
    );
  }
}
