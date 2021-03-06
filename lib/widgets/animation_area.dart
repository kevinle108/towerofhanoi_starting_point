import 'package:flutter/material.dart';
import 'rod_widget.dart';
import 'disk_widget.dart';
import '../constants_enums.dart';
import '../controllers/disks_brain.dart';

class AnimationArea extends StatelessWidget {
  final DisksBrain disksBrain;
  final Function onTap;

  AnimationArea(
      {required this.disksBrain, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 450,
        //color: Colors.lightGreen,
        child: Stack(
          //alignment: Alignment.bottomLeft,
          children: [
            for (int i = 0; i < 3; i++)
              RodWidget(
                  rodIndex: i, onTap: onTap),
            for (var disk in disksBrain.disks)
              DiskWidget(
                disk: disk,
              ),
          ],
        ));
  }
}
