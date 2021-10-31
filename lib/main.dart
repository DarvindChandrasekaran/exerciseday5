import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const MyHomePage(title: 'Ticks Details'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String symbol = '';
  String data = '';
  List symbols = [];
  List tickHistory = [];
  dynamic symbolDetails;
  final channel = IOWebSocketChannel.connect(
      'wss://ws.binaryws.com/websockets/v3?app_id=1089');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _controller = TextEditingController();

  void getData(symbol) {
    tickHistory.clear();
    channel.stream.listen((tick) {
      final decodedMessage = jsonDecode(tick);
      final name = decodedMessage['tick']['symbol'];
      final serverTimeAsEpoch = decodedMessage['tick']['epoch'];
      final price = decodedMessage['tick']['quote'];
      final serverTime =
          DateTime.fromMillisecondsSinceEpoch(serverTimeAsEpoch * 1000);

      setState(() {
        tickHistory.add({"Name": name, "Price": price, "Date": serverTime});
      });
      print('Name: ${name}, Price: ${price}, Date: ${serverTime}');
    });

    channel.sink.add('{"ticks": "$symbol"}');
  }

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'cryBTCUSD: ',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _formKey.currentState?.validate() ?? false
                          ? () {
                              getData(symbol);
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_rounded),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a Valid Symbol Please';
                    }
                    return null;
                  },
                  onChanged: (String? value) {
                    setState(() {
                      symbol = value!;
                    });
                  },
                ),
                tickHistory.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: tickHistory.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  color: Colors.amberAccent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Name: ${tickHistory[index]["Name"]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Price: ${tickHistory[index]["Price"]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Date: ${tickHistory[index]["Date"]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }))
                    : Container()
              ],
            ),
          ),
        ));
  }
}


//   channel.stream.listen((tick) {
//     // ignore: unused_local_variable
//     final decodedMessage = jsonDecode(tick);
//     final serverTimeAsEpoch = decodedMessage['tick']['epoch'];
//     final price = decodedMessage['tick']['quote'];
//     final name = decodedMessage['tick']['symbol'];
//     final serverTime =
//         DateTime.fromMillisecondsSinceEpoch(serverTimeAsEpoch * 1000);
//     print('Name: $name' + ' ' + 'Price: $price' + ' ' + 'Date: $serverTime');
//   });

//   channel.sink.add('{"ticks": "frxAUDCAD"}');
// }
