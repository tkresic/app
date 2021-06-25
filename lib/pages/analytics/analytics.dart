import 'dart:convert';
import 'dart:io';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/middleware.dart';
import 'package:intl/intl.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:app/util/http_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key}) : super(key: key);

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {

  @override
  http.Client client = InterceptedClient.build(interceptors: [
    ApiInterceptor(),
  ]);

  List<IncomeData> income = [];
  List<ProfitData> sales = [];
  List<QuantityData> quantities = [];

  Future<Map<dynamic, dynamic>> fetchData() async {
    var response = await client.get(
        Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/analytics"),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    data["income"].keys.forEach((i) => {
      income.add(IncomeData(i, data["income"][i]))
    });

    data["sales"].keys.forEach((i) => {
      sales.add(ProfitData(i, data["sales"][i], NumberFormat.compactCurrency(decimalDigits: 1, symbol: "").format(data["sales"][i]).trim() + " HRK"))
    });

    data["quantities"].keys.forEach((i) => {
      quantities.add(QuantityData(i, data["quantities"][i]))
    });

    return {
      "data" : response.body,
    };
  }

  @override
  Widget build(BuildContext context) {

    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Middleware();
    }

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: const Drawer(
        child: DrawerList(index: 6),
      ),
      appBar: const CustomAppBar(),
      body: Row(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<Map<dynamic, dynamic>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.error.runtimeType == SocketException) {
                    return const Center(child: Text("Došlo je do greške. Mikroservis vjerojatno nije u funkciji."));
                  } else {
                    return const Center(child: Text("Došlo je do greške."));
                  }
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                               Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text('Analitika', style: TextStyle(color: Colors.black, fontSize: 20))
                              ),
                            ]
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  primaryYAxis: NumericAxis(numberFormat: NumberFormat.currency(locale: 'hr')),
                                  title: ChartTitle(text: 'Prihod'),
                                  series: <LineSeries<IncomeData, String>>[
                                    LineSeries<IncomeData, String>(
                                      color: Colors.orange,
                                      dataSource: income,
                                      xValueMapper: (IncomeData data, _) => data.label,
                                      yValueMapper: (IncomeData data, _) => data.amount,
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        textStyle: const TextStyle(color: Colors.black, fontSize: 11),
                                        color: Colors.white,
                                      ),
                                      animationDuration: 500,
                                    )
                                  ]
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: SfCircularChart(
                                  title: ChartTitle(text: 'Najprofitabilniji proizvodi'),
                                  legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom
                                  ),
                                  palette: const [Color(0x00003f5c), Color(0x0058508d), Color(0x00bc5090), Color(0x00ff6361), Color(0x00ffa600)],
                                  series: <PieSeries<ProfitData, String>>[
                                    PieSeries<ProfitData, String>(
                                      dataSource: sales,
                                      xValueMapper: (ProfitData data, _) => data.label,
                                      yValueMapper: (ProfitData data, _) => data.amount,
                                      dataLabelMapper: (ProfitData data, _) => data.format,
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        textStyle: const TextStyle(color: Colors.black, fontSize: 11),
                                        color: Colors.white,
                                      ),
                                      animationDuration: 500,
                                    )
                                  ]
                                )
                              ),
                              Expanded(
                                child: SfCircularChart(
                                title: ChartTitle(text: 'Najprodavaniji proizvodi'),
                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom
                                ),
                                series: <DoughnutSeries<QuantityData, String>>[
                                  DoughnutSeries<QuantityData, String>(
                                    dataSource: quantities,
                                    xValueMapper: (QuantityData data, _) => data.label,
                                    yValueMapper: (QuantityData data, _) => data.amount,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 11),
                                      color: Colors.white,
                                    ),
                                    animationDuration: 500,
                                  )
                                ]
                                )
                              ),
                            ],
                          ),
                        ]
                      )
                    )
                  );
                } else {
                  return const Loader(message: "Dohvaćam podatke...");
                }
              },
            )
          )
        ]
      ),
    );
  }
}

class IncomeData {
  final String label;
  final num amount;

  IncomeData(this.label, this.amount);
}

class ProfitData {
  final String label;
  final num amount;
  final String format;

  ProfitData(this.label, this.amount, this.format);
}

class QuantityData {
  final String label;
  final int amount;

  QuantityData(this.label, this.amount);
}