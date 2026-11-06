import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/servicesApi.dart';
import 'package:frontend/models/liquidaciones.dart';

class DetalleLiquidacion extends StatefulWidget {
  final int id;

  const DetalleLiquidacion({super.key, required this.id});

  @override
  State<DetalleLiquidacion> createState() => _DetalleLiquidacionState();
}

class _DetalleLiquidacionState extends State<DetalleLiquidacion> {
  Liquidaciones? liquidacion;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cargarDetalle();
  }

  Future<void> cargarDetalle() async {
    try {
      final resultado = await ServicesApi().liquidacionShow(widget.id);

      if (!mounted) return;

      setState(() {
        liquidacion = resultado;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No fue posible cargar la liquidación.';
        isLoading = false;
      });

      debugPrint('ERROR DETALLE: $error');
    }
  }

  String formatNum(double? number) {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    ).format(number ?? 0);
  }

  Widget construirDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 15)),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liquidación #${widget.id}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : liquidacion == null
          ? const Center(child: Text('Liquidación no encontrada.'))
          : _construirContenido(),
    );
  }

  Widget _construirContenido() {
    final dato = liquidacion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de liquidación',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          Text('Registro #${dato.id}'),

          if (dato.fecha_creacion != null)
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(dato.fecha_creacion!)}',
            ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  construirDato('IBC', formatNum(dato.ibc)),
                  const Divider(),
                  construirDato('Salud (12.5%)', formatNum(dato.salud)),
                  const Divider(),
                  construirDato('Pensión (16%)', formatNum(dato.pension)),
                  const Divider(),
                  construirDato('ARL', formatNum(dato.arl)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de ARL',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  construirDato(
                    'Nivel de riesgo',
                    dato.nivelArl?.toString() ?? 'No disponible',
                  ),
                  construirDato(
                    'Porcentaje',
                    dato.porcentaje != null
                        ? '${(dato.porcentaje! * 100).toStringAsFixed(3)}%'
                        : 'No disponible',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'TOTAL DE APORTES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatNum(dato.total),
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
