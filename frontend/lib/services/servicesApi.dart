import 'package:http/http.dart' as http;
import 'package:frontend/models/TarifaArl.dart';
import 'package:frontend/models/crearLiquidaciones.dart';
import 'package:frontend/models/liquidaciones.dart';
import 'package:frontend/config/apiConfig.dart';

import 'dart:convert';

//http.get(Uri.parse(url)>

class ServicesApi {
  static Future<List<TarifaArl>> nivelArl() async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/arl"));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => TarifaArl.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Liquidaciones>> liquidacionIndex() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/liquidaciones"),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Liquidaciones.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load liquidations');
    }
  }

  Future<Liquidaciones> liquidacionShow(int id) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/liquidaciones/$id"),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Liquidaciones.fromJson(jsonData);
    } else {
      throw Exception('Failed to load liquidation');
    }
  }

  Future<Liquidaciones> liquidacionCreate(CrearLiquidaciones solicitud) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/liquidaciones"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'sueldo': solicitud.sueldo,
        'tarifaArl_id': solicitud.tarifaArl_id,
      }),
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return Liquidaciones.fromJson(jsonData);
    } else {
      throw Exception('Failed to create liquidation');
    }
  }
}
