
class Asistencia{

  String idAsistencia;
  String fecha;
  String idAlumno;
  String estado;
  String idGrupo;

  Asistencia({this.idAsistencia, this.fecha, this.idAlumno, this.estado, this.idGrupo});

  Asistencia.fromJsonMap(Map<dynamic,dynamic> json){
    idAsistencia = json['id'].toString();
    fecha        = json['fecha'].toString();
    idAlumno     = json['id_alumno'].toString();
    estado       = json['estado'].toString();
    idGrupo      = json['id_grupo'].toString();
  }

    Map<String, dynamic> toJson() => {
        "fecha"     : fecha,
        "id_alumno" : idAlumno,
        "estado"    : estado,
        "id_grupo"  : idGrupo
    };
}