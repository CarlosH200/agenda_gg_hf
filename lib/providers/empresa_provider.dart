import 'package:flutter/material.dart';

class EmpresaProvider extends ChangeNotifier {
  String empresaActual = 'golden';

  void cambiarEmpresa(String empresa) {
    empresaActual = empresa;
    notifyListeners();
  }
}
