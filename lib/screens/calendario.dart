import 'package:flutter/material.dart';
import 'detalle_dia.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});
  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late DateTime _fechaActualBase;
  final List<String> _mesesNombres = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  @override
  void initState() {
    super.initState();
    _fechaActualBase = DateTime.now();
  }

  void _cambiarMes(int factor) {
    setState(() {
      _fechaActualBase = DateTime(_fechaActualBase.year, _fechaActualBase.month + factor, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    int diasEnMes = DateTime(_fechaActualBase.year, _fechaActualBase.month + 1, 0).day;
    int primerDiaSemana = DateTime(_fechaActualBase.year, _fechaActualBase.month, 1).weekday;
    String textoCabecera = "${_mesesNombres[_fechaActualBase.month - 1]} ${_fechaActualBase.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
                onPressed: () => _cambiarMes(-1),
              ),
              Text(
                textoCabecera,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF1E293B)),
                onPressed: () => _cambiarMes(1),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("Lu", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("Ma", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("Mi", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("Ju", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("Vi", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("Sá", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("Do", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: diasEnMes + (primerDiaSemana - 1),
              itemBuilder: (context, index) {
                int diaNumero = index - (primerDiaSemana - 2);
                if (diaNumero <= 0) return const SizedBox.shrink();

                return InkWell(
                  onTap: () {
                    DateTime fechaFiltroCalendario = DateTime(_fechaActualBase.year, _fechaActualBase.month, diaNumero);
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleDia(
                          fechaSeleccionada: fechaFiltroCalendario,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$diaNumero",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}