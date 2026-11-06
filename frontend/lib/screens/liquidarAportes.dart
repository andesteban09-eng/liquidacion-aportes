import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/servicesApi.dart';
import 'package:frontend/models/TarifaArl.dart';
import 'package:frontend/models/liquidaciones.dart';
import 'package:frontend/models/crearLiquidaciones.dart';
import 'package:frontend/screens/historialLiquidaciones.dart';

class CalcularAportes extends StatefulWidget {
  const CalcularAportes({super.key});

  @override
  State<CalcularAportes> createState() => CalcularAportesState();
}

class CalcularAportesState extends State<CalcularAportes> {
  final TextEditingController ibcController = TextEditingController(
    text: '1.500.000',
  );
  Liquidaciones? resultadoLiquidacion;
  bool isCalculating = false;
  String? errorLiquidation;
  //definir variables que en algun momento podrian tener un valor null
  List<TarifaArl> tarifas = [];
  TarifaArl? tarifaSeleccionada;
  bool isLoading = true;
  String? errorMessage;

  @override
  // este metodo se llama cuando se destruye el widget, para recargar el estado y para limpiar el controlador
  void dispose() {
    ibcController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchTarifas();
  }

  Future<void> fetchTarifas() async {
    try {
      final tarifasData = await ServicesApi.nivelArl();
      if (!mounted) return;
      setState(() {
        tarifas = tarifasData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget filaResultado(String titulo, double? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 15)),
          Text(
            formatNum(valor),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String formatNum(double? number) {
    if (number == null) {
      return NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(0);
    }
    NumberFormat formatter = NumberFormat.currency(locale: "es", symbol: "\$");
    String formatted = formatter.format(number);
    return formatted;
  }

  Future<void> liquidarAportes() async {
    // 1. Obtener y validar el sueldo
    final sueldoTexto = ibcController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final sueldo = double.tryParse(sueldoTexto);

    if (sueldo == null || sueldo <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un sueldo válido')));
      return;
    }

    // 2. Comprobar que se haya seleccionado una tarifa
    if (tarifaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un nivel de riesgo')),
      );
      return;
    }

    // 3. Enviar la petición al backend
    setState(() {
      isCalculating = true;
      errorLiquidation = null;
    });

    try {
      final solicitud = CrearLiquidaciones(
        sueldo: sueldo,
        tarifaArl_id: tarifaSeleccionada!.id,
      );

      final resultado = await ServicesApi().liquidacionCreate(solicitud);

      if (!mounted) return;

      // 4. Guardar la respuesta y actualizar la interfaz
      setState(() {
        resultadoLiquidacion = resultado;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorLiquidation = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liquidación de aportes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de liquidaciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistorialLiquidaciones(),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ENCABEZADO
            const Text(
              'Calculadora de aportes',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Ingresa los datos del cotizante para calcular '
              'sus aportes al sistema de seguridad social.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            // FORMULARIO
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos del cotizante',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SUELDO
                    TextField(
                      controller: ibcController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FormatoMiles()],
                      decoration: const InputDecoration(
                        labelText: 'Sueldo mensual',
                        prefixText: '\$ ',
                        suffixText: 'COP',
                        prefixIcon: Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(),
                        helperText: 'Ingresa el sueldo en pesos colombianos',
                      ),
                    ),

                    const SizedBox(height: 22),

                    // TARIFA ARL
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (errorMessage != null)
                      Text(
                        'Error al cargar las tarifas: $errorMessage',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      DropdownButtonFormField<TarifaArl>(
                        initialValue: tarifaSeleccionada,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Nivel de riesgo ARL',
                          prefixIcon: Icon(Icons.health_and_safety_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: tarifas.map((tarifa) {
                          return DropdownMenuItem<TarifaArl>(
                            value: tarifa,
                            child: Text(
                              'Nivel ${tarifa.nivelArl} '
                              '(${(tarifa.porcentaje * 100).toStringAsFixed(3)}%)',
                            ),
                          );
                        }).toList(),
                        onChanged: (nuevaTarifa) {
                          setState(() {
                            tarifaSeleccionada = nuevaTarifa;
                          });
                        },
                      ),

                    const SizedBox(height: 25),

                    // BOTÓN CALCULAR
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: isCalculating || isLoading
                            ? null
                            : liquidarAportes,
                        icon: isCalculating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.calculate_outlined),
                        label: Text(
                          isCalculating ? 'Calculando...' : 'Calcular aportes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (errorLiquidation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorLiquidation!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // RESULTADOS
            if (resultadoLiquidacion != null) ...[
              const Text(
                'Resultado de la liquidación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      filaResultado(
                        'Ingreso base de cotización (IBC)',
                        resultadoLiquidacion!.ibc,
                      ),

                      const Divider(),

                      filaResultado(
                        'Salud (12.5%)',
                        resultadoLiquidacion!.salud,
                      ),

                      const Divider(),

                      filaResultado(
                        'Pensión (16%)',
                        resultadoLiquidacion!.pension,
                      ),

                      const Divider(),

                      filaResultado('ARL', resultadoLiquidacion!.arl),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // TOTAL
              Card(
                elevation: 2,
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Text(
                        'TOTAL DE APORTES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        formatNum(resultadoLiquidacion!.total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 15),

              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 55,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aquí aparecerán los resultados',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Completa los datos y calcula tus aportes.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

class FormatoMiles extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitos.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final numero = int.tryParse(digitos);

    if (numero == null) return oldValue;

    final textoFormateado = NumberFormat.decimalPattern('es_CO').format(numero);

    return TextEditingValue(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: textoFormateado.length),
    );
  }
}
