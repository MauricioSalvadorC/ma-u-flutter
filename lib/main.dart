import 'package:flutter/material.dart';

void main() {
  runApp(const CalculoNotaApp());
}

class CalculoNotaApp extends StatelessWidget {
  const CalculoNotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cálculo Nota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PantallaCalculadora(),
    );
  }
}

class PantallaCalculadora extends StatefulWidget {
  const PantallaCalculadora({super.key});

  @override
  State<PantallaCalculadora> createState() => _PantallaCalculadoraState();
}

class _PantallaCalculadoraState extends State<PantallaCalculadora> {
  final corte1Controller = TextEditingController();
  final corte2Controller = TextEditingController();
  final notaDeseadaController = TextEditingController();
  final corte3Controller = TextEditingController();

  String resultadoNotaNecesaria = '';
  String resultadoNotaFinal = '';

  double? convertirNota(String texto) {
    final textoLimpio = texto.trim().replaceAll(',', '.');
    return double.tryParse(textoLimpio);
  }

  void calcularNotaNecesaria() {
    final corte1 = convertirNota(corte1Controller.text);
    final corte2 = convertirNota(corte2Controller.text);
    final notaDeseada = convertirNota(notaDeseadaController.text);

    if (corte1 == null || corte2 == null || notaDeseada == null) {
      setState(() {
        resultadoNotaNecesaria =
            'Ingresa correctamente corte 1, corte 2 y nota deseada.';
      });
      return;
    }

    final notaNecesaria = (notaDeseada - corte1 * 0.3 - corte2 * 0.3) / 0.4;

    setState(() {
      resultadoNotaNecesaria =
          'Necesitas sacar ${notaNecesaria.toStringAsFixed(2)} en el tercer corte.';
    });
  }

  void calcularNotaFinal() {
    final corte1 = convertirNota(corte1Controller.text);
    final corte2 = convertirNota(corte2Controller.text);
    final corte3 = convertirNota(corte3Controller.text);

    if (corte1 == null || corte2 == null || corte3 == null) {
      setState(() {
        resultadoNotaFinal =
            'Ingresa correctamente corte 1, corte 2 y posible corte 3.';
      });
      return;
    }

    final notaFinal = corte1 * 0.3 + corte2 * 0.3 + corte3 * 0.4;

    setState(() {
      resultadoNotaFinal = 'Tu nota final sería ${notaFinal.toStringAsFixed(2)}.';
    });
  }

  void limpiarCampos() {
    corte1Controller.clear();
    corte2Controller.clear();
    notaDeseadaController.clear();
    corte3Controller.clear();

    setState(() {
      resultadoNotaNecesaria = '';
      resultadoNotaFinal = '';
    });
  }

  @override
  void dispose() {
    corte1Controller.dispose();
    corte2Controller.dispose();
    notaDeseadaController.dispose();
    corte3Controller.dispose();
    super.dispose();
  }

  Widget campoNota({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget tarjetaResultado(String texto) {
    if (texto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de nota'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Calculadora del tercer corte',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Corte 1: 30% • Corte 2: 30% • Corte 3: 40%',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            campoNota(
              label: 'Nota corte 1',
              controller: corte1Controller,
            ),

            const SizedBox(height: 16),

            campoNota(
              label: 'Nota corte 2',
              controller: corte2Controller,
            ),

            const SizedBox(height: 24),

            campoNota(
              label: 'Nota final que quieres sacar',
              controller: notaDeseadaController,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: calcularNotaNecesaria,
                child: const Text(
                  'Calcular nota necesaria',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 12),

            tarjetaResultado(resultadoNotaNecesaria),

            const SizedBox(height: 28),

            campoNota(
              label: 'Posible nota corte 3',
              controller: corte3Controller,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: calcularNotaFinal,
                child: const Text(
                  'Calcular nota final',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 12),

            tarjetaResultado(resultadoNotaFinal),

            const SizedBox(height: 28),

            TextButton(
              onPressed: limpiarCampos,
              child: const Text('Limpiar campos'),
            ),
          ],
        ),
      ),
    );
  }
}