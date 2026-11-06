class CrearLiquidaciones {
  final double sueldo;
  final int tarifaArl_id;

 CrearLiquidaciones({  
    required this.sueldo,
    required this.tarifaArl_id,
  });
  factory CrearLiquidaciones.fromJson(Map<String, dynamic> json) {
    return CrearLiquidaciones(
      sueldo: (json['sueldo'] as num).toDouble(),
      tarifaArl_id: json['tarifaArl_id'] as int,
    );
  }
}
