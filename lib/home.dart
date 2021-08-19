import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zebra_trackaware/constants.dart';
import 'package:zebra_trackaware/logics/pageRoute.dart';
import 'package:zebra_trackaware/pages/tender.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Color(0xFF100F0F),
        width: double.infinity,
        height: double.infinity,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(toPage(Tender()));
                },
                icon: Container(height: verticalPixel * 20, width: verticalPixel * 20, color: Colors.white, child: SvgPicture.asset('asset/')))
          ],
        ),
      ),
    );
  }
}
