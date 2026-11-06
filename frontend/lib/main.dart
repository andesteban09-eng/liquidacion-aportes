import 'package:flutter/material.dart';
import 'package:frontend/screens/liquidarAportes.dart';
import 'package:frontend/services/servicesApi.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tarifas = await ServicesApi.nivelArl();

  for (var tarifa in tarifas) {
    print('Nivel: ${tarifa.nivelArl}');
    print('Porcentaje: ${tarifa.porcentaje}');
  }

  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: CalcularAportes()),
      debugShowCheckedModeBanner: false,
    );
  }
}
