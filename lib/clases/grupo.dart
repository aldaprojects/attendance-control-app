
import 'alumno.dart';

class Grupo{

  String idGrupo;
  String nombre;
  List<Alumno> alumnos = new List();
  

  Grupo({this.idGrupo, this.nombre});

  set setAlumnos(List<Alumno> students) => alumnos = students;

  Grupo.fromJsonMap(Map<dynamic,dynamic> json){
    idGrupo     = json['id'].toString();
    nombre      = json['nombre'];
  }
}