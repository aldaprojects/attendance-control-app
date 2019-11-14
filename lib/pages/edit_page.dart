
import 'dart:io';

import 'package:asistencia/clases/alumno.dart';
import 'package:asistencia/clases/asistencia.dart';
import 'package:asistencia/clases/fechas.dart';
import 'package:asistencia/clases/grupo.dart';
import 'package:asistencia/providers/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class Aux{
  String fecha;
  Alumno alumno;

  Aux({this.fecha, this.alumno});
}

class EditarAlumnos extends StatefulWidget {
  @override
  _EditarAlumnosState createState() => _EditarAlumnosState();
}

List<Alumno> alumnos;
List<Asistencia> asistencias;
Grupo grupo;
File foto;

class _EditarAlumnosState extends State<EditarAlumnos> {


  TextEditingController matriculaAlumno = new TextEditingController();
  TextEditingController nombreAlumno    = new TextEditingController();

  List<Fechas> fechas = new List();
  

  @override
  Widget build(BuildContext context) {


    

    List todo = ModalRoute.of(context).settings.arguments;

    grupo       = todo[0];
    alumnos     = todo[1];
    asistencias = todo[2];


    List<Aux> lista = new List();
    for(Asistencia asistencia in asistencias){
      for(Alumno alumno in alumnos){
        if(alumno.idAlumno == asistencia.idAlumno){
          Alumno alum = new Alumno(
            foto: alumno.foto,
            idAlumno: alumno.idAlumno,
            idGrupo: alumno.idGrupo,
            matricula: alumno.matricula,
            nombre: alumno.nombre
          );
          alum.estado = asistencia.estado == "0" ? false : true;
          Aux a = new Aux(
            fecha: asistencia.fecha,
            alumno: alum
          );
          lista.add(a);
          break;
        }
      }
    }
    List<Fechas> fechas = new List();
    List<Alumno> alums = new List();
    String fechaAux = "";
    if(lista.length > 0 ){
      fechaAux = lista.first.fecha;
    }
    for(Aux a in lista){
      if(fechaAux == a.fecha){
        alums.add(a.alumno);
      }
      else{
        Fechas fecha = new Fechas(
          fecha: fechaAux,
          alumnos: alums
        );
        fechas.add(fecha);
        alums = new List();
        fechaAux = a.fecha;
        alums.add(a.alumno);
      }
    }

    Fechas fecha = new Fechas(
      fecha: fechaAux,
      alumnos: alums
    );
    fechas.add(fecha);


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.date_range)),
            ],
          ),
          title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Alumnos de ${grupo.nombre}'),
            Expanded(child: Container()),
            Text('TOTAL:${alumnos.length}', style: TextStyle(fontSize: 15))
          ],
        )
        ),
        body: TabBarView(
          children: [
            Center(
              child: alumnos.length >0 ? ListView.builder(
                itemCount: alumnos.length,
                itemBuilder: (context, index){
                  return _cardAlumno(alumnos[index], alumnos[index].foto);
                }
              ) :
              Container(
                child: Text('No hay registros creados actualmente.', style: TextStyle(fontSize: 20),),
              ),
            ),
            Center(
              child: alumnos.length >0 ? ListView.builder(
                itemCount: fechas.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: (){
                      List todo = new List();
                      todo.add(fechas[index].fecha);
                      todo.add(grupo.nombre);
                      todo.add(fechas[index].alumnos);
                      Navigator.pushNamed(context, 'fechas', arguments: todo);
                    },
                    child: Card(
                      color: Colors.white60,
                      child: ListTile(
                        title: Text(fechas[index].fecha, style: TextStyle(fontSize: 18)),
                        trailing: Icon(Icons.arrow_right),
                      ),
                    ),
                  );
                },
              ) :
              Container(
                child: Text('No hay registros creados actualmente.', style: TextStyle(fontSize: 20),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAlumno(Alumno alumno, String path){ 
    return Column(
      children: <Widget>[
        Container(
          height: 110,
          padding: EdgeInsets.only(top: 10),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5.0,
            child: ListTile(
              leading: GestureDetector(
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  child: path != "nada" && path != "null" ? Image.file(File(path)) : Icon(Icons.person),
                ),
                onTap: (){
                  _tomarFoto(alumno);
                },
              ),
              title: GestureDetector(
                onTap: (){
                  _masInfo(path, alumno.nombre);
                },
                child: Text(alumno.nombre, style: TextStyle(fontSize: 19))
              ),
              subtitle: Text(alumno.matricula, style: TextStyle(fontSize: 17)),
            ),
          ),
        )
      ],
    );
  }

  _tomarFoto(Alumno alumno) async {
    
    foto = await ImagePicker.pickImage(
      source: ImageSource.camera
    );
    setState(() {
      DBProvider.db.updateFotoAlumno(foto.path, alumno);
      alumno.foto = foto.path;
    });

  }

  // _deleteAlumno(Alumno alumno){
  //   showDialog(
  //     context: context,
  //     builder: (context){
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
  //         title: Center(child: Text('¿Esta seguro que desea eliminar ${alumno.nombre}?')),
  //         elevation: 15,
  //         actions: <Widget>[
  //           Row(
  //             children: <Widget>[
  //               FlatButton(
  //                 child: Text('ELIMINAR'),
  //                 onPressed: (){setState(() {
  //                  DBProvider.db.deleteAlumnobyId(int.parse(alumno.idAlumno));
  //                  alumnos.remove(alumno); 
  //                  Navigator.of(context).pop();
  //                 });},
  //               ),
  //               FlatButton(
  //                 child: Text('CANCELAR'),
  //                 onPressed: (){Navigator.of(context).pop();},
  //               )
  //             ],
  //           )
  //         ],

  //       );
  //     }
  //   );
  // }

  _masInfo(String path, String nombre){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Center(
            child: Column(
              children: <Widget>[
                Container(
                 child: path != "nada" && path != "null" ? Image.file(File(path)) : Icon(Icons.person),
                ),
                SizedBox(height: 20),
                Text(nombre)
              ],
            )
          ),
        );
      }
    );
  }
}
  // _formularioCrearAlumno(){
  //   var now = new DateTime.now();
  //   String fecha = '${now.year}-${now.month}-${now.day}';
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context){
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
  //         title: Center(
  //           child: Column(
  //             children: <Widget>[
  //               Center(
  //                 child: Text('Nuevo Alumno')
  //               ),
  //               SizedBox(height: 20),
  //               TextField(
  //                 controller: nombreAlumno,
  //                 decoration: InputDecoration(
  //                   labelText: 'Nombre del alumno',
  //                   hintText: 'Introduzca el nombre del alumno'
  //                 ),
  //               ),
  //               TextField(
  //                 controller: matriculaAlumno,
  //                 decoration: InputDecoration(
  //                   labelText: 'Matricula del alumno',
  //                   hintText: 'Introduzca la matricula del alumno'
  //                 ),
  //               )
  //             ],
  //           )
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: Text('CREAR'),
  //             onPressed: (){
  //               final matricula = matriculaAlumno.text;
  //               final nombre    = nombreAlumno.text;
  //               if(matricula.isEmpty || nombre.isEmpty){
  //                 showDialog(
  //                   context: context,
  //                   builder: (context){
  //                     return AlertDialog(
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
  //                       title: Center(
  //                         child: Column(
  //                           children: <Widget>[
  //                             Center(
  //                               child: Text('Ambos campos no deben estar vacios.')
  //                             )
  //                           ],
  //                         )
  //                       ),
  //                       actions: <Widget>[
  //                         FlatButton(
  //                           child: Text('OK'),
  //                           onPressed: () => Navigator.of(context).pop()
  //                         )
  //                       ],
  //                     );
  //                   }
  //                 );
  //               }
  //               else{
  //                 Alumno alumno = new Alumno(
  //                   nombre: nombreAlumno.text,
  //                   matricula: matriculaAlumno.text,
  //                   idGrupo: grupo.idGrupo,
  //                   foto: "null"
  //                 );
  //                 DBProvider.db.nuevoAlumnosinId(alumno);
  //                 int id;
  //                 FutureBuilder(
  //                   future: DBProvider.db.getTodosAlumnos(),
  //                   builder: (context, AsyncSnapshot<List<Alumno>> snapshot){
  //                     List<Alumno> alumnos = snapshot.data;
  //                     if(snapshot.hasData){
  //                       alumnos.forEach((a){
  //                         if(a.matricula == alumno.matricula){
  //                           id = int.parse(a.idAlumno);
  //                         }
  //                       });
  //                     }
  //                   },
  //                 );
  //                 Asistencia asistencia = new Asistencia(
  //                   fecha: fecha,
  //                   estado: "0",
  //                   idAlumno: id.toString(),
  //                   idGrupo: alumno.idGrupo
  //                 );
  //                 DBProvider.db.nuevaAsitenciaRam(asistencia);
  //                 FutureBuilder(
  //                   future: DBProvider.db.getTodasAsistenciasbyFecha(fecha),
  //                   builder: (context, AsyncSnapshot snapshot){
  //                     asistencias = snapshot.data;
  //                   },
  //                 );
  //                 Navigator.of(context).pop();
  //                 setState(() {alumnos.add(alumno);});
  //               }
  //             }
  //           ),
  //           FlatButton(
  //             child: Text('CANCELAR'),
  //             onPressed: () => Navigator.of(context).pop()
  //           )
  //         ],
  //       );
  //     }
  //   );
  // }

