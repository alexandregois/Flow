import 'dart:async';

import 'package:flutter/material.dart';

class LeaveDown extends StatefulWidget {
  final Widget child;
  final int delay;
  final int duration;
  final double offset;

  LeaveDown({@required this.child, this.delay, this.duration, this.offset});

  @override
  _LeaveDownState createState() => _LeaveDownState();
}

class _LeaveDownState extends State<LeaveDown> with TickerProviderStateMixin {
  AnimationController _animController;
  Animation<Offset> _slideOffset;
  Animation<double> _fadeOffset;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration ?? 250),
    );
    final curve = CurvedAnimation(curve: Curves.ease, parent: _animController);
    _slideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, widget.offset ?? 1.0),
    ).animate(curve);

    _fadeOffset = Tween<double>(begin: 1.0, end: 0.0).animate(_animController);

    if (widget.delay == null) {
      _animController.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _slideOffset,
        child: widget.child,
      ),
      opacity: _fadeOffset,
    );
  }
}
