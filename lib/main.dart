import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/models/transaction.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import './components/transaction_list.dart';

main() {
  runApp(ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  final ThemeData tema = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
        theme: tema.copyWith(
          colorScheme: tema.colorScheme.copyWith(
            primary: Colors.purple,
            secondary: Colors.amber,
          ),
          textTheme: tema.textTheme.copyWith(
            titleLarge: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );
    setState(() {
      _transactions.add(newTransaction);
    });

    //Fechando o modal quando o formulário é submetido
    //No caso, o context é o próprio modal
    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) {
        return tr.id == id;
      });
    });
  }

  _openTransacionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final appBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text('Despesas Pessoais'),
      actions: [
        if (isLandscape)
          IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
            icon: Icon(_showChart ? Icons.list : Icons.show_chart),
          ),
        IconButton(
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () => _openTransacionFormModal(context),
          icon: const Icon(Icons.add),
        ),
      ],
    );

    //Tamanho disponível = altura da tela - tamanho do appBar
    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

        //Aqui fica o body
        final bodyPage = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showChart == true || isLandscape == false)
                    Container(
                      child: Chart(_recentTransactions),
                      height: availableHeight * (isLandscape ? 0.7 : 0.3),
                    ),
                  if (!_showChart || isLandscape == false)
                    Container(
                      height: availableHeight * (isLandscape ? 1 : 0.7),
                      child: TransactionList(_transactions, _removeTransaction),
                    ),
                ],
              ),
            );

    return Scaffold(
            appBar: appBar,
            body: bodyPage,
            floatingActionButton: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () => _openTransacionFormModal(context),
                    child: const Icon(Icons.add),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
