import 'dart:convert';

import 'package:e_fu/module/arrange.dart';
import 'package:e_fu/request/e/e.dart';
import 'package:e_fu/request/e/e_data.dart';
import 'package:e_fu/request/record/record.dart';
import 'package:e_fu/myData.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:e_fu/request/data.dart';
import 'package:e_fu/request/record/record_data.dart';

class Event extends StatefulWidget {
  static const routeName = '/event';

  const Event({super.key});

  @override
  State<StatefulWidget> createState() => EventState();
}

class EventState extends State<Event> {
  List<EAppointmentDetail> selected_arrange = [];
  bool isBleOn = false;
  bool isScan = false;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  //沒連線的裝置
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  Map<int, String> connectDeviec = {};
  List<BluetoothCharacteristic> characteristic_list = [];
  List<Record> to_save = [];
  List<BluetoothDevice> hasPair = [];
  AsciiDecoder asciiDecoder = const AsciiDecoder();
  String number = "0";
  List<String> exercise_item = ["左手", "右手"];
  ERepo eRepo = ERepo();
  bool notyet=true;

  Future<List<EAppointmentDetail>> getData(EAppointment eAppointment) async {
    Format d = await eRepo.getApDetail(
        "11136008", eAppointment.id.start_date, eAppointment.id.time);
    return parseEApointmentDetail(jsonEncode(d.D));
  }

  @override
  void initState() {
   
    print("this isis initstate");
    // FlutterBluePlus.instance.state.listen((state) {
    //   if (state == BluetoothState.on) {
    //     print('藍牙狀態爲開啓');
    //     setState(() {
    //       isBleOn = true;
    //     });
    //   } else if (state == BluetoothState.off) {
    //     print('藍牙狀態爲關閉');
    //     setState(() {
    //       isBleOn = false;
    //     });
    //   }
    // });
  }

  //偵測是否在列印裝置
  _scan() {
    FlutterBluePlus.instance.isScanning.listen((event) {
      setState(() {
        isScan = event;
      });
    });
  }

  Widget toPairDialog(int pIndex) {
    return SizedBox(
      width: double.minPositive,
      height: 200,
      child: StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.instance.scanResults,
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: snapshot.data!.map(
            (r) {
              if (r.advertisementData.connectable && r.device.name != "") {
                if (r.device.name.substring(0, 4) == "e-fu" ||
                    r.device.name.substring(0, 4) == "Ardu") {
                  // print(r.device.services);
                  return ListTile(
                    title: Text(r.device.name),
                    onTap: () async {
                      List<BluetoothService> _services = [];

                      try {
                        await r.device.connect();
                      } on PlatformException catch (e) {
                        if (e.code != 'already_connected') {
                          rethrow;
                        }
                      } finally {
                        _services = await r.device.discoverServices();
                      }
                      setState(() {
                        hasPair.add(r.device);
                        connectDeviec[pIndex] = r.device.id.toString();
                      });

                      print("連接到${r.device.name}");
                      print(connectDeviec);
                      for (BluetoothCharacteristic characteristic
                          in _services.first.characteristics) {
                        print(characteristic.uuid.toString());
                        if (characteristic.uuid.toString() ==
                            "0000ff00-0000-1000-8000-00805f9b34fb") {
                          characteristic_list.add(characteristic);
                        } else if (characteristic.uuid.toString() ==
                            "0000ff01-0000-1000-8000-00805f9b34fb") {
                          characteristic.value.listen((value) {
                            print("enter heree");
                            try {
                              print("from number:$value");

                              number = String.fromCharCodes(value);
                            } catch (e) {
                              print("number char errors");
                            }
                          });
                        } else {
                          characteristic.value.listen((value) {
                            try {
                              String string = String.fromCharCodes(value);
                              List<String> raw = string.split(",");

                              to_save.add(Record(
                                  double.parse(raw[0]),
                                  double.parse(raw[1]),
                                  double.parse(raw[2]),
                                  double.parse(raw[3]),
                                  double.parse(raw[4]),
                                  double.parse(raw[5])));
                            } catch (e) {
                              print("error:$e");
                            }
                          });
                          await characteristic.setNotifyValue(true);
                        }
                      }
                      Navigator.of(context).pop();
                    },
                  );
                } else {
                  return Container();
                }
              } else {
                return Container();
              }
            },
          ).toList(),
        ),
      ),
    );
  }

  var recordRepo = RecordRepo();

  Widget exercise_box(index) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('${selected_arrange[index].name}'),
          Row(
              children: List.generate(
                  exercise_item.length,
                  (eIndex) => Expanded(
                        child: Column(
                          children: [
                            Text(exercise_item[eIndex]),
                            Container(
                              width: 30,
                              margin: EdgeInsets.all(5),
                              height: 30,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 5),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  color: Colors.white),
                              child: Center(
                                child: Text(
                                    '${selected_arrange[index].item[eIndex]}'),
                              ),
                            )
                          ],
                        ),
                      ))),
          GestureDetector(
            child: Container(
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: MyTheme.color),
                child: Text(
                  "連接",
                  style: whiteText(),
                  textAlign: TextAlign.center,
                )),
            onTap: () async {
              FlutterBluePlus.instance.state.listen((state) {
                if (state == BluetoothState.on) {
                  print('藍牙狀態爲開啓');
                  setState(() {
                    isBleOn = true;
                  });
                } else if (state == BluetoothState.off) {
                  print('藍牙狀態爲關閉');
                  setState(() {
                    isBleOn = false;
                  });
                }
              });
              if (isBleOn) {
                _scan();
                //沒在列印的時候再startScan
                if (!isScan) {
                  flutterBlue.startScan(timeout: const Duration(seconds: 4));
                }
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("您已開啟藍芽"),
                    content: toPairDialog(index),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Text("關閉"),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                await showDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                          content: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Align(
                                alignment: Alignment(0, 0),
                                child: Text("是否要開啟藍芽？"),
                              )
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('取消'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('開啟藍芽'),
                              onPressed: () async {
                                await FlutterBluePlus.instance
                                    .turnOn()
                                    .then((value) {
                                  setState(() {
                                    isBleOn = true;
                                  });
                                });
                                _scan();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ));
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     final args = ModalRoute.of(context)!.settings.arguments as EAppointment;
    if(selected_arrange.isEmpty&notyet){
      
    getData(args).then(
      (value) {
       setState(() {
          selected_arrange = value;
       });
        notyet=false;
      },
    );
    }
    return (Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MyTheme.backgroudColor,
      body: SafeArea(
        child: Column(children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const Expanded(
                  flex: 2,
                  child: Text(
                    "復健",
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  )),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
          SizedBox(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    selected_arrange.isEmpty?Text("error"):
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: GridView.count(
                        crossAxisCount: 2,
                        children:
                            List.generate(selected_arrange.length, (index) {
                          return (exercise_box(index));
                        }),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: MyTheme.lightColor),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                characteristic_list.forEach((element) {
                                  element.write(utf8.encode("true"));
                                });
                              },
                              icon: const Icon(Icons.not_started_rounded),
                            ),
                            Text(
                              "全部開始",
                              style: whiteText(),
                            )
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        print(to_save.length);
                        Format a = await recordRepo
                            .record(Arrange_date("t01", to_save));
                        if (a.message == "ok") {
                          print("成功");
                        }
                      },
                      child: const Text("傳送"),
                    ),
                    TextButton(
                      onPressed: () async {
                        for (var element in hasPair) {
                          element.disconnect();
                        }
                        setState(() {
                          connectDeviec = {};
                          hasPair = [];
                        });
                      },
                      child: const Text("關閉"),
                    ),
                  ],
                )),
          )
        ]),
      ),
    ));
  }
}
