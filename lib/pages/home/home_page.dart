import 'dart:convert';

import 'package:age_calculator/age_calculator.dart';
import 'package:e_fu/module/exercise_process.dart';
import 'package:e_fu/module/page.dart';
import 'package:e_fu/module/toast.dart';
import 'package:e_fu/pages/event/event.dart';
import 'package:e_fu/pages/exercise/event_record.dart';
import 'package:e_fu/pages/exercise/insert.dart';
import 'package:e_fu/request/e/e_data.dart';
import 'package:e_fu/request/plan/plan_data.dart';

import 'package:e_fu/module/box_ui.dart';
import 'package:e_fu/my_data.dart';
import 'package:e_fu/request/user/get_user_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userID});
  final String userID;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String userName = "柯明朗";
  late SharedPreferences prefs;
  late GetUser getUser;
  List<ItemWithField> targetCheck = ItemSets.withField();
  Logger logger = Logger();

  @override
  initState() {
    super.initState();
    test();
  }

  Future<void> test() async {
    prefs = await SharedPreferences.getInstance();
    try {
      getUser =
          GetUser.fromJson(jsonDecode(prefs.get(Name.getUser).toString()));
    } catch (e) {
      logger.v(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Cubed M",
      headTexttype: TextType.page,
      headHeight: MediaQuery.of(context).size.height * 0.12,
      body: SizedBox(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Box.boxHasRadius(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.29,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                            bottom: Radius.circular(0),
                          ),
                          color: MyTheme.color,
                        ),
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Container(
                            alignment: Alignment.center,
                            child: textWidget(
                                text: "運動日程",
                                type: TextType.sub,
                                color: Colors.white)),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: textWidget(
                                        text: "今天 ${index * 2 + 21}:00",
                                        type: TextType.content),
                                  ),
                                );
                              }, childCount: 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Box.boxHasRadius(
                  width: MediaQuery.of(context).size.width * 0.46,
                  height: MediaQuery.of(context).size.height * 0.29,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Container(
                            alignment: Alignment.center,
                            child: textWidget(text: "分析圖", type: TextType.sub)),
                      ),
                      Expanded(
                        child: Box.boxHasRadius(
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: MediaQuery.of(context).size.width * 0.33,
                          child: Chart.avgChart([5, 3, 1]),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Box.boxHasRadius(
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              height: MediaQuery.of(context).size.height * 0.22,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            child:
                                textWidget(text: "運動計畫", type: TextType.sub)),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  Row(children: Box.executeWeek(show: true)),
                  Row(
                    children: Box.planWeek(
                        Plan(
                            name: "",
                            end_date: DateTime.now(),
                            user_id: '',
                            str_date: DateTime.now(),
                            execute: [
                              true,
                              true,
                              false,
                              false,
                              true,
                              true,
                              false
                            ]),
                        exe: [true, true, false, false, false, true, false]),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setTarget(
                      context,
                      targetCheck,
                      yes: () => Navigator.pushReplacementNamed(
                        context,
                        Event.routeName,
                        arguments: [
                          EventRecord(
                              eventRecordDetail: EventRecordDetail(
                                item: targetCheck
                                    .map((e) =>
                                        int.parse(e.textEditingController.text))
                                    .toList(),
                              ),
                              eventRecordInfo: EventRecordInfo(
                                  name: getUser.name,
                                  age: AgeCalculator.age(getUser.birthday)
                                      .years, user_id: widget.userID))
                        ],
                      ),
                      no: () => Navigator.pop(context),
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Box.boxHasRadius(
                    boxShadow: Box.getshadow(MyTheme.color),
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: MediaQuery.of(context).size.height * 0.13,
                    child: Center(
                      child: textWidget(text: '肌力運動', type: TextType.sub),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () =>
                      Navigator.pushNamed(context, InsertInvite.routeName),
                  child: Box.boxHasRadius(
                    boxShadow: Box.getshadow(MyTheme.color),
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: MediaQuery.of(context).size.height * 0.13,
                    child: Center(
                        child: textWidget(text: "邀約運動", type: TextType.sub)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
