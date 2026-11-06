class Liquidaciones {
  final int id;
  final double ibc;
  final double salud;
  final double pension;
  final double arl;
  final double total;
  final String? descripcion;
  final DateTime? fecha_creacion;
  final int tarifaArl_id;
  final double? porcentaje;
  final int? nivelArl;
  Liquidaciones({
    required this.id,
    required this.ibc,
    required this.salud,
    required this.pension,
    required this.arl,
    required this.total,
    required this.descripcion,
    required this.fecha_creacion,
    required this.tarifaArl_id,
    required this.porcentaje,
    required this.nivelArl,
  });
  factory Liquidaciones.fromJson(Map<String, dynamic> json) {
    return Liquidaciones(
      id: (json['id'] as num).toInt(),
      ibc: double.parse(json['ibc'].toString()),
      salud: double.parse(json['salud'].toString()),
      pension: double.parse(json['pension'].toString()),
      arl: double.parse(json['arl'].toString()),
      total: double.parse(json['total'].toString()),
      descripcion: json['descripcion'] as String?,
      fecha_creacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
      tarifaArl_id: json['tarifaarl_id'] as int,
      porcentaje: json['porcentaje'] != null
          ? double.parse(json['porcentaje'])
          : null,
      nivelArl: json['nivelarl'] != null
          ? int.parse(json['nivelarl'].toString())
          : null,
    );
  }
}
