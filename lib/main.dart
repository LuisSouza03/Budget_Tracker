import 'package:budget_tracker/budget_repository.dart';
import 'package:budget_tracker/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:budget_tracker/failure_model.dart';
import 'package:intl/intl.dart';

import 'item_model.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notion Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
      home: const BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = BudgetRepository().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _futureItems = BudgetRepository().getItems();
          setState(() {});
        },
        child: FutureBuilder<List<Item>>(
          future: _futureItems,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Show pie chart and list view of items.
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return SpendingChart(items: items);

                  final item = items[index - 1];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        width: 2.0,
                        color: getCategoryColor(item.category),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        )
                      ],
                    ),
                    // Name
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      textColor: Colors.black,
                      // Info
                      subtitle: RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.local_offer,
                                size: 20,
                                color: Colors.orange,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${item.category} - ${DateFormat('dd/MM/yyyy').format(item.date)} \n',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const WidgetSpan(
                              child: Icon(
                                Icons.push_pin,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: '${item.type} - ${item.payment}',
                            )
                          ],
                        ),
                      ),
                      // Price
                      trailing: RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.attach_money_outlined,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: getAmountType(item.payment, item.price),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: (FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              // Show failure error message.
              final failure = snapshot.error as Failure;
              return Center(child: Text(failure.message));
            }
            // Show a loading spinner
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// Color getCategoryColor(String category) {
//   switch (category) {
//     case 'Entertainment':
//       return Colors.red[400]!;
//     case 'Food':
//       return Colors.green[400]!;
//     case 'Personal':
//       return Colors.blue[400]!;
//     case 'Transportation':
//       return Colors.purple[400]!;
//     default:
//       return Colors.orange[400]!;
//   }
// }

Color getCategoryColor(String category) {
  switch (category) {
    case 'Supérfluo':
      return Colors.red[400]!;
    case 'Comida e bebida':
      return Colors.green[400]!;
    case 'Educação':
      return Colors.blue[400]!;
    case 'Transporte':
      return Colors.purple[400]!;
    case 'Mercado':
      return Colors.yellow[400]!;
    case 'Shopping':
      return Colors.pink[400]!;
    case 'Saúde':
      return Colors.blueAccent[400]!;
    case 'Pagamento Fatura':
      return Colors.lightGreenAccent[400]!;

    default:
      return Colors.orange[400]!;
  }
}

String getAmountType(String payment, double price) {
  switch (payment) {
    case 'Crédito':
      return '-R\$${price.toStringAsFixed(2).replaceAll('.', ',')}';
    case 'Débito':
      return '+R\$${price.toStringAsFixed(2).replaceAll('.', ',')}';

    default:
      return '-R\$${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
