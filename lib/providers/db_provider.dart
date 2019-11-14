import 'dart:io';

import 'package:asistencia/clases/alumno.dart';
import 'package:asistencia/clases/asistencia.dart';
import 'package:asistencia/clases/grupo.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {

  static Database _database; 
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {

    if ( _database != null ) return _database;

    _database = await initDB();
    return _database;
  }


  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join( documentsDirectory.path, 'asistencia.db' );

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: ( Database db, int version ) async {
        await db.execute(
          'CREATE TABLE alumnos ('
          ' id INTEGER PRIMARY KEY,'
          ' nombre TEXT,'
          ' matricula INTEGER,'
          ' mac TEXT DEFAULT nada,'
          ' foto TEXT DEFAULT null,'
          ' id_grupo INTEGER'
          ')'
        );
        await db.execute(
          'CREATE TABLE asistencias ('
          ' id INTEGER PRIMARY KEY,'
          ' fecha TEXT,'
          ' id_alumno TEXT,'
          ' estado INTEGER DEFAULT 0,'
          ' id_grupo INTEGER'
          ')'
        );
        await db.execute(
          'CREATE TABLE grupos ('
          ' id INTEGER PRIMARY KEY,'
          ' nombre TEXT'
          ')'
        );
      }
    
    );

  }

  // CREAR Registros
  nuevoGrupoRaw( Grupo nuevoGrupo ) async {

    final db  = await database;

    final res = await db.rawInsert(
      "INSERT INTO grupos (nombre) "
      "VALUES ('${ nuevoGrupo.nombre }')"
    );
    return res;

  }
  nuevaAsitenciaRam( Asistencia nuevaAsistencia ) async {

    int estado  = int.parse('${ nuevaAsistencia.estado }');
    int idGrupo = int.parse('${ nuevaAsistencia.idGrupo }');

    final db  = await database;

    final res = await db.rawInsert(
      "INSERT INTO asistencias (fecha, id_alumno, estado, id_grupo) "
      "VALUES ('${ nuevaAsistencia.fecha }', '${ nuevaAsistencia.idAlumno }', $estado, $idGrupo)"
    );
    return res;

  }

  nuevoAlumnoRaw( Alumno nuevoAlumno ) async {

    final idAlumno = int.parse(nuevoAlumno.idAlumno);
    final matricula = int.parse(nuevoAlumno.matricula);
    final idGrupo  = int.parse(nuevoAlumno.idGrupo);

    final db  = await database;

    final res = await db.rawInsert(
      "INSERT INTO alumnos (id, nombre, matricula, id_grupo) "
      "VALUES ($idAlumno, '${ nuevoAlumno.nombre }', $matricula, $idGrupo)"
    );
    return res;

  }

    nuevoAlumnosinId( Alumno nuevoAlumno ) async {

    final matricula = int.parse(nuevoAlumno.matricula);
    final idGrupo  = int.parse(nuevoAlumno.idGrupo);

    final db  = await database;

    final res = await db.rawInsert(
      "INSERT INTO alumnos (nombre, matricula, id_grupo) "
      "VALUES ('${ nuevoAlumno.nombre }', $matricula, $idGrupo)"
    );
    return res;

  }

  // SELECT - Obtener información

  Future<List<Grupo>> getTodosGrupos() async {

    final db  = await database;
    final res = await db.query('grupos');


    List<Grupo> list = res.isNotEmpty 
                              ? res.map( (c) => Grupo.fromJsonMap(c) ).toList()
                              : [];

    return list;
  }

  Future<List<Alumno>> getTodosAlumnos() async {

    final db  = await database;
    final res = await db.query('alumnos', orderBy: 'nombre');


    List<Alumno> list = res.isNotEmpty 
                              ? res.map( (c) => Alumno.fromJsonMap(c) ).toList()
                              : [];

    return list;
  }

  Future<List<Asistencia>> getTodasAsistencias() async {

    final db  = await database;
    final res = await db.query('asistencias');

    List<Asistencia> list = res.isNotEmpty 
                              ? res.map( (c) => Asistencia.fromJsonMap(c) ).toList()
                              : [];

    return list;
  }
  
  Future<List<Asistencia>> getTodasAsistenciasbyFecha(String fecha) async {

    final db  = await database;
    final res = await db.query('asistencias', where: 'fecha = ?', whereArgs: [fecha]);


    List<Asistencia> list = res.isNotEmpty 
                              ? res.map( (c) => Asistencia.fromJsonMap(c) ).toList()
                              : [];

    return list;
  }

  Future<List<Asistencia>> getTodasAsistenciasbyGrupo(int idGrupo) async {

    final db  = await database;
    final res = await db.query('asistencias', where: 'id_grupo = ?', whereArgs: [idGrupo]);


    List<Asistencia> list = res.isNotEmpty 
                              ? res.map( (c) => Asistencia.fromJsonMap(c) ).toList()
                              : [];

    return list;
  }

  Future<List<Alumno>> getTodosAlumnosbyID(int id) async {

    final db  = await database;
    final res = await db.query('alumnos', where: 'id_grupo = ?', whereArgs: [id], orderBy: 'nombre');


    List<Alumno> list = res.isNotEmpty 
                              ? res.map( (c) => Alumno.fromJsonMap(c) ).toList()
                              : [];

    return list;
  }

  // // Actualizar Registros

  Future<int> updateAsistencia(Asistencia asistencia) async {
    final idAlumno = int.parse(asistencia.idAlumno);
    final fecha    = asistencia.fecha;

    final db = await database;
    final res = await db.update('asistencias', asistencia.toJson(), where: 'fecha = ? and id_alumno = ?', whereArgs: [fecha, idAlumno]);
    return res;
  }

  Future<int> updateFotoAlumno(String path, Alumno alumno) async {

    final idAlumno = int.parse(alumno.idAlumno);

    final db = await database;

    final res = await db.update('alumnos', {"foto" : path}, where: 'id = ?', whereArgs: [idAlumno]);
    return res;
  }

  Future<int> updateMac( String mac, int idAlumno ) async {

    final db = await database;

    final res = await db.update('alumnos', {"mac" : mac}, where:  'id = ?', whereArgs: [idAlumno]);

    return res;
  }

  // Eliminar registros
  Future<int> deleteGrupo( int id ) async {

    final db  = await database;
    final res = await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteGrupos() async {

    final db  = await database;
    final res = await db.rawDelete('DELETE FROM grupos');
    return res;
  }

  Future<int> deleteAlumnos() async {

    final db  = await database;
    final res = await db.rawDelete('DELETE FROM alumnos');
    return res;
  }

  Future<int> deleteAlumnobyId( int idAlumno ) async {

    final db  = await database;
    final res = await db.delete('alumnos',where: 'id = ?', whereArgs: [idAlumno]);
    return res;
  }

  Future<int> deleteAsistencias() async {

    final db  = await database;
    final res = await db.rawDelete('DELETE FROM asistencias');
    return res;
  }

}

