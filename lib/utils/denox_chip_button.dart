import 'package:flutter/material.dart';

class DenoxChipButton extends StatelessWidget {
  final VoidCallback onTap;

//  final double size;
  final Widget icon;
  final Widget title;
  final bool bordered;
  final Color borderColor;
  final double borderWidth;
  final bool isHorizontal;
  final double padding;

  DenoxChipButton({
    this.onTap,
//    this.size,
    this.icon,
    this.title,
    this.padding,
    this.bordered = true,
    this.borderColor,
    this.isHorizontal = true,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final borderColor = this.borderColor ?? (theme.brightness == Brightness.dark ? Colors.white : theme.buttonColor);
    final border = bordered ? (borderColor) : Colors.transparent;

    List<Widget> children;
    bool isCircularBorder = false;

    if (this.icon != null) {
      if (this.title != null) {
        children = <Widget>[
          this.icon,
          SizedBox(width: 8),
          this.title ?? Container(),
        ];
      } else {
        children = <Widget>[
          Padding(padding: const EdgeInsets.all(4), child: this.icon),
        ];

        isCircularBorder = true;
      }
    } else {
      children = <Widget>[
        this.title ?? Container(),
      ];
    }

    Widget parent;

    if (isHorizontal) {
      parent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    } else {
      parent = Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    var borderSide = BorderSide(color: border, width: borderWidth);
    return Material(
      shape: isCircularBorder ? CircleBorder(side: borderSide) : StadiumBorder(side: borderSide),
      color: Colors.black.withAlpha(100),
      child: SizedBox(
//        height: size,
        child: InkWell(
          customBorder: isCircularBorder ? CircleBorder() : StadiumBorder(),
          onTap: onTap,
          child: Center(
              child: Padding(
            padding: EdgeInsets.all(padding ?? 10),
            child: parent,
          )),
        ),
      ),
    );
  }
}