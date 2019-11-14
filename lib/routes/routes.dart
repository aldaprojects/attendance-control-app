import 'package:asistencia/pages/edit_page.dart';
import 'package:asistencia/pages/fechas_page.dart';
import 'package:asistencia/pages/list_page.dart';
import 'package:flutter/material.dart';

import '../main.dart';



Map<String, WidgetBuilder> getRoutes(){

  return <String, WidgetBuilder>{
    '/'             : (BuildContext context) => HomePage(),
    'editarAlumnos' : (BuildContext context) => EditarAlumnos(),
    'pasarLista'    : (BuildContext context) => PasarLista(),
    'fechas'        : (BuildContext context) => FechaPage()
  };


}