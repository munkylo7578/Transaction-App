import "dart:io";
import 'package:finished_job/widgets/chart.dart';
import 'package:finished_job/widgets/new_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'models/transaction.dart';
import './widgets/transaction_list.dart';

import "./widgets/new_transaction.dart";

void main() {
  /* WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]); */
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter app",
      home: MyHomePage(),
      theme: ThemeData(
          errorColor: Colors.red,
          fontFamily: "Quicksand",
          textTheme: ThemeData.light().textTheme.copyWith(
                titleMedium: const TextStyle(
                    fontFamily: "OpenSans",
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
          appBarTheme: AppBarTheme(
              textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(fontFamily: "OpenSans", fontSize: 20))),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.amber)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    /* Transaction(
        id: "t1", title: "New Shoes", amount: 69.99, date: DateTime.now()),
    Transaction(
        id: "t2", title: "Groceries", amount: 70.99, date: DateTime.now()), */
  ];
  bool _showChart = false;
  List<Transaction> get _recentTransaction {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).toList();
  }

  void _addNewTransaction(String title, double amount, DateTime chosenDate) {
    var newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        date: chosenDate);
    setState(() {
      _userTransactions.add(newTransaction);
    });
  }

  final titleController = TextEditingController();

  final amountController = TextEditingController();

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          /* onTap: () {}, */
          child: NewTransaction(_addNewTransaction),
          /* behavior: HitTestBehavior.opaque, */
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text("Flutter App"),
            trailing: Row(
              children: [
                IconButton(
                    onPressed: () {
                      _startAddNewTransaction(context);
                    },
                    icon: const Icon(
                      Icons.add,
                    )),
              ],
            ),
          )
        : AppBar(
            title: const Text("Flutter App"),
            actions: [
              IconButton(
                  onPressed: () {
                    _startAddNewTransaction(context);
                  },
                  icon: const Icon(
                    Icons.add,
                  )),
            ],
          ) as PreferredSizeWidget;
    final txListWidget = Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.7,
        child: TransactionList(_userTransactions, _deleteTransaction));
    final pageBody = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (isLandscape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Show chart"),
                Switch.adaptive(
                  value: _showChart,
                  onChanged: (bool value) {
                    setState(() {
                      _showChart = value;
                    });
                  },
                )
              ],
            ),
          if (!isLandscape)
            Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.3,
                child: Chart(_recentTransaction)),
          if (!isLandscape) txListWidget,
          if (isLandscape)
            _showChart
                ? Container(
                    height: (mediaQuery.size.height -
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        0.7,
                    child: Chart(_recentTransaction))
                : txListWidget
        ],
      ),
    );
    return SafeArea(
      child: Platform.isIOS
          ? CupertinoPageScaffold(
              child: pageBody,
              navigationBar: appBar as ObstructingPreferredSizeWidget,
            )
          : Scaffold(
              appBar: appBar,
              body: pageBody,
              floatingActionButton: Platform.isIOS
                  ? Container()
                  : Builder(
                      builder: (context) => FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: () => _startAddNewTransaction(context)),
                    ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
    );
  }
}/*  */
