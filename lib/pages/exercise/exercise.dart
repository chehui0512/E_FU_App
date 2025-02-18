import 'dart:convert';

import 'package:e_fu/module/box_ui.dart';
import 'package:e_fu/module/page.dart';
import 'package:e_fu/my_data.dart';
import 'package:e_fu/request/exercise/history.dart';
import 'package:e_fu/request/exercise/history_data.dart';
import 'package:e_fu/request/invite/invite.dart';
import 'package:e_fu/request/invite/invite_data.dart';

import 'package:flutter/material.dart';

class ExerciseHome extends StatefulWidget {
  final String userID;
  const ExerciseHome({super.key, required this.userID});

  @override
  State<StatefulWidget> createState() => ExerciseHomeState();
}

class ExerciseHomeState extends State<ExerciseHome>
    with SingleTickerProviderStateMixin {
  // 宣告 TabController
  late TabController tabController;
  InviteRepo inviteRepo = InviteRepo();
  HistoryRepo historyRepo = HistoryRepo();

  List<Invite> invitelist = [];
  List<History> hisotrylist = [];

  int mode = 3;

  @override
  void initState() {
    // 建立 TabController，vsync 接受的型態是 TickerProvider
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    inviteRepo.inviteList(widget.userID, mode).then((value) {
      List<Invite> inviteList = parseInviteList(jsonEncode(value.D));
      setState(() {
        invitelist = inviteList;
      });
    });
    historyRepo.historyList(widget.userID).then((value) {
      List<History> historyList = parseHistoryList(jsonEncode(value.D));
      setState(() {
        hisotrylist = historyList;
      });
    });
  }

  void filter(int m) {
    setState(() {
      mode = m;
    });
    inviteRepo.inviteList(widget.userID, mode).then((value) {
      List<Invite> inviteList = parseInviteList(jsonEncode(value.D));
      setState(() {
        invitelist = inviteList;
      });
    });
  }

  List<Widget> getfilterButtons() {
    List<Widget> result = [];
    final filters = ['未回覆', "已接受", '已拒絕'];
    final filtersID = [3, 1, 2];

    for (int i = 0; i < filters.length; i++) {
      result.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => filter(filtersID[i]),
        child: Box.textRadiusBorder(filters[i],
            margin: const EdgeInsets.all(5),
            color: mode == filtersID[i] ? Colors.white : MyTheme.color,
            filling: mode == filtersID[i] ? MyTheme.color : Colors.white,
            border: MyTheme.color,
            width: 75),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
        body: Column(
      children: [
        TabBar(
          indicatorColor: MyTheme.color,
          labelColor: MyTheme.color,
          unselectedLabelColor: MyTheme.hintColor,
          controller: tabController,
          tabs: const [
            Tab(
                child: Text("邀約",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center)),
            Tab(
                child: Text("歷史運動",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: getfilterButtons()),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: invitelist.length,
                      itemBuilder: (BuildContext context, int index) {
                        return (Box.inviteBox(invitelist[index], context));
                      },
                    ),
                  ),
                ],
              ),
              Column(children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [textWidget(text: "篩選", type: TextType.content)],
                  ),
                ),
                Expanded(
                  child: Box.boxHasRadius(
                    color: MyTheme.backgroudColor,
                    child: ListView.builder(
                        itemCount: hisotrylist.length,
                        itemBuilder: (BuildContext context, int index) {
                          return (Box.history(
                              hisotrylist[index], context, widget.userID));
                        }),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    ));
  }
}
