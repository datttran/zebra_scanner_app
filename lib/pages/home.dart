import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zebra_trackaware/constants.dart';
import 'package:zebra_trackaware/pages/tender.dart';

import '../logics/pageRoute.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 360,
        height: 512,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xffeceefb), Color(0xfffafcff)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: verticalPixel * 5,
                  ),
                  Icon(Entypo.dots_two_horizontal),
                  Text(
                    "    TRACKAWARE",
                    style: TextStyle(
                      color: Color(0xff1c1c1c),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: verticalPixel * 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ORDERS",
                        style: TextStyle(
                          color: Color(0xff1c1c1c),
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        "You have 2 orders",
                        style: TextStyle(
                          fontFamily: "Roboto Mono",
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 309,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: Color(0xffe3e3e3),
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 18,
                top: 6,
                bottom: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: SizedBox(
                      width: 81,
                      height: 21,
                      child: Text(
                        "Details",
                        style: TextStyle(
                          color: Color(0xff1c1c1c),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPixel * 3),
                  Container(
                    width: 270,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Color(0xffc4c4c4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: verticalPixel * 50,
              width: horizontalPixel * 90,
              color: Colors.transparent,
              child: GridView.count(
                crossAxisCount: 3,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(toPage(Tender()));
                    },
                    child: Container(
                      width: 87,
                      height: 87,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 87,
                            height: 87,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xffe2e2e2),
                            ),
                            padding: EdgeInsets.only(
                              left: verticalPixel * 2,
                              right: 22,
                              top: 5,
                              bottom: 62,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/list-svgrepo-com.svg',
                                height: verticalPixel * 105,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 87,
                    height: 87,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 87,
                          height: 87,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Color(0xffe2e2e2),
                          ),
                          padding: EdgeInsets.only(
                            left: verticalPixel * 2,
                            right: 22,
                            top: 5,
                            bottom: 62,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 44,
                                height: 20,
                                child: Text(
                                  "Pickup",
                                  style: TextStyle(
                                    color: Color(0xff1c1c1c),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 87,
                    height: 87,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 87,
                          height: 87,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Color(0xffe2e2e2),
                          ),
                          padding: EdgeInsets.only(
                            left: verticalPixel * 2,
                            top: 5,
                            bottom: 62,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 51,
                                height: 20,
                                child: Text(
                                  "Deliver",
                                  style: TextStyle(
                                    color: Color(0xff1c1c1c),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 97,
              height: 32,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 97,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xffc4c4c4),
                    ),
                    padding: const EdgeInsets.only(
                      left: 28,
                      right: 29,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 18,
                          child: Text(
                            "START",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
