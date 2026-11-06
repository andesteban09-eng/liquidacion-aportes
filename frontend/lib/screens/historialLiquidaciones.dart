import 'package:flutter/material.dart';
import 'package:frontend/services/servicesApi.dart';
import 'package:frontend/models/liquidaciones.dart';
import 'package:intl/intl.dart';
import 'package:frontend/screens/detalleLiquidacion.dart';

class HistorialLiquidaciones extends StatefulWidget {
  const HistorialLiquidaciones({super.key});

  @override
  State<HistorialLiquidaciones> createState() => HistorialLiquidacionesState();
}

class HistorialLiquidacionesState extends State<HistorialLiquidaciones> {
  final ServicesApi api = ServicesApi();
  List<Liquidaciones> liquidaciones = [];
  bool isLoading = true;
  String? errorMessage;
  String formatNum(double? number) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return formatter.format(number ?? 0);
  }

  @override
  void initState() {
    super.initState();
    fetchLiquidaciones();
  }

  Future<void> fetchLiquidaciones() async {
    try {
      final liquidacionesData = await api.liquidacionIndex();
      if (!mounted) return;
      setState(() {
        liquidaciones = liquidacionesData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Error al cargar las liquidaciones: $e';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de liquidaciones')),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : liquidaciones.isEmpty
          ? const Center(child: Text('No hay liquidaciones registradas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: liquidaciones.length,
              itemBuilder: (context, index) {
                final liquidacion = liquidaciones[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.receipt_long),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleLiquidacion(id: liquidacion.id),
                        ),
                      );
                    },
                    title: Text('Liquidación #${liquidacion.id}'),
                    subtitle: Text(
                      liquidacion.fecha_creacion != null
                          ? 'Fecha: ${liquidacion.fecha_creacion}'
                          : 'Fecha no disponible',
                    ),
                    trailing: Text(
                      formatNum(liquidacion.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
