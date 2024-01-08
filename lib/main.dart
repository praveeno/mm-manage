import 'package:flutter/material.dart';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallet/fn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Month End'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SmsQuery _query = SmsQuery();
  List<MoneyTransaction> _messages = [];
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  getSms() async {
    // var permission = await Permission.sms.status;
    var count = 0;
    // if (permission.isGranted) {
    // while (count < 1000) {
    final messages = mockSms();
    // final messages = await _query.querySms(
    //   start: count,
    //   kinds: [SmsQueryKind.inbox],
    //   count: 10,
    // );
    count += messages.length;
    var decMonth = DateTime(2022, DateTime.january, 1);
    var msgs = messages;
    // var msgs = messages.where((element) => element.date!.isAfter(decMonth));
    if (msgs.isEmpty) {
      debugPrint('No more messages');
      // break;
    } else {
      setState(() {
        var x = processAndAnalyzeSMS(msgs);
        print(x.length.toString());
        _messages.addAll(x);
      });
    }
    // }
    // } else {
    //   await Permission.sms.request();
    // }
  }

  @override
  void initState() {
    // getSms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(widget.title),
      ),
      body: _MessagesListView(
        messages: _messages,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _incrementCounter();
              getSms();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.get_app),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _messages = [];
              });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _MessagesListView extends StatelessWidget {
  const _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<MoneyTransaction> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                print(message.body);
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(message.date.toString(),
                          style: Theme.of(context).textTheme.headline6),
                      Text(
                        message.body ?? 'No message body',
                      ),
                      // add more widgets here
                    ],
                  ),
                );
              },
            );
          },
          child: ListTile(
            title: Text('${message.title}'),
            subtitle: Text('₹ ${message.amount}'),
          ),
        );
      },
    );
  }
}
