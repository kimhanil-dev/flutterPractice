import 'package:acter_project/screen/main.dart';
import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class UICredit extends UI {
  UICredit(this.playerNames, {super.key});

  final List<String> playerNames;

  @override
  State<UICredit> createState() => _UICreditState();

  @override
  bool get isForward => false;
}

class _UICreditState extends State<UICredit> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CreditData creditData = Provider.of<CreditData>(context);

    List<Widget> credit = [];

    var groups = creditData.data.keys;
    for (var group in groups) {
      List<Row> rows = [];
      for (var person in creditData.data[group]!) {
        // add credit line
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Text(
              person.role,
              textAlign: TextAlign.end,
            )),
            Expanded(child: Text(person.name))
          ],
        ));
      }

      // make credit group
      credit.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(group, style: const TextStyle(fontSize: 50)),
          ),
          ...rows,
        ],
      ));
    }

    // 관객이름 추가
    List<Widget> names = [];
    for (var name in widget.playerNames) {
      names.add(
        Text(name),
      );
    }

    credit.add(Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(30),
          child: Text('테아트론', style: TextStyle(fontSize: 50)),
        ),
        ...names,
      ],
    ));

    // 연극 이름
    credit.add(Padding(
      padding: const EdgeInsets.all(30),
      child: Image.asset('assets/logo.png')),
    );

    credit.add(Padding(
      padding: const EdgeInsets.all(30),
      child: Image.asset('assets/logo.png')),
    );


    return Scaffold(
        body: OverflowBox(
      maxHeight: double.infinity,
      child: DefaultTextStyle(
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        child: Column(children: [...credit])
            .animate()
            .slideY(duration: 10.seconds, begin: 1, end: -1)
            //.fadeOut(delay: 1.seconds)
        ),
      ),
    );
  }
}
