class TarifaArl {
 final int  id;
  final String  nivelArl;
  final double porcentaje;
  final String? descripcion;

  TarifaArl({
    required this.id,
    required this.nivelArl,
    required this.porcentaje,
    this.descripcion,
  });

  factory TarifaArl.fromJson(Map<String, dynamic> json) {
    return TarifaArl(
      id: json['id'],
      nivelArl: json['nivelarl'],
      porcentaje: double.parse(json['porcentaje']),
      descripcion: json['descripcion'],
    );
  }

}
