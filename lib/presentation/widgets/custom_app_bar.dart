import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Size size;
  final String title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    this.size = const Size.fromHeight(60),
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ?? Builder(
        builder: (ctx) => InkWell(
          child: Image.asset('assets/icons/icon.png', width: 10,),
          onTap: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: actions,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => size;
}
