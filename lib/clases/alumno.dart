
class Alumno{

  String idAlumno;
  String nombre;
  String matricula;
  String mac;
  String foto;
  String idGrupo;
  bool estado = false;

  Alumno({this.idAlumno, this.nombre, this.matricula, this.foto, this.idGrupo});

  Alumno.fromJsonMap(Map<dynamic,dynamic> json){
    idAlumno  = json['id'].toString();
    nombre    = json['nombre'].toString();
    matricula = json['matricula'].toString();
    foto      = json['foto'].toString();
    idGrupo   = json['id_grupo'].toString();
    mac       = json['mac'].toString();
  }

}