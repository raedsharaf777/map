import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/my_colors.dart';
import 'package:maps/constants/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);
  PhoneAuthCubit phoneAuthCubit = PhoneAuthCubit();

  Widget buildDrawerHeader(context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[500],
          ),
          child: Image.asset(
            'assets/images/raed.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Text(
          'Raed El-Husseiny',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        BlocProvider<PhoneAuthCubit>(
          create: (_) => phoneAuthCubit,
          child: Text(
            '${phoneAuthCubit.getLoggedInUserData().phoneNumber}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildDrawerListItem(
      {required IconData leadingIcon,
      required String title,
      Widget? trailing,
      Function()? onTap,
      Color? color}) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: color ?? MyColors.blue,
      ),
      title: Text(title),
      // error ---> ??=
      trailing: trailing ??
          Icon(
            Icons.arrow_right,
            color: MyColors.blue,
          ),
      onTap: onTap,
    );
  }

  Widget buildDrawerListItemsDivider() {
    return Divider(
      height: 0,
      thickness: 1,
      indent: 18,
      endIndent: 24,
    );
  }

  void _lanchURL(String url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Widget buildIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _lanchURL(url),
      child: Icon(
        icon,
        color: MyColors.blue,
        size: 35,
      ),
    );
  }

  Widget buildSocialMediaIcon() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 26),
      child: Row(
        children: [
          buildIcon(FontAwesomeIcons.facebook,
              'https://www.facebook.com/raed.sharaf.33/'),
          const SizedBox(
            width: 15,
          ),
          buildIcon(
              FontAwesomeIcons.github, 'https://github.com/raedsharaf777'),
          const SizedBox(
            width: 20,
          ),
          buildIcon(
              FontAwesomeIcons.linkedin, 'https://www.linkedin.com/feed/'),
        ],
      ),
    );
  }

  Widget buildLogout(context) {
    return Container(
      child: BlocProvider<PhoneAuthCubit>(
        create: (context) => phoneAuthCubit,
        child: buildDrawerListItem(
            leadingIcon: Icons.logout,
            title: 'LogOut',
            trailing: SizedBox(),
            color: Colors.red,
            onTap: () async {
              await phoneAuthCubit.logOut();
              Navigator.of(context).popAndPushNamed(loginScreen);
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 300,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[500]),
              child: buildDrawerHeader(context),
            ),
          ),
          buildDrawerListItem(leadingIcon: Icons.person, title: 'My Profile'),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(
              leadingIcon: Icons.history,
              title: 'Places History',
              onTap: () {}),
          buildDrawerListItem(leadingIcon: Icons.settings, title: 'Settings'),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.help, title: 'Help'),
          buildDrawerListItemsDivider(),
          buildLogout(context),
          const SizedBox(height: 70),
          ListTile(
            leading: Text(
              'Follow Us',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          buildSocialMediaIcon(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
