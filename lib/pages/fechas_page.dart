import 'dart:io';

import 'package:asistencia/clases/alumno.dart';
import 'package:flutter/material.dart';

class FechaPage extends StatelessWidget {

  List<Alumno> alumnos;

  int asis;
  int total;

  @override
  Widget build(BuildContext context) {
    List todo = ModalRoute.of(context).settings.arguments;

    String fecha = todo[0];
    String grupo = todo[1];
    alumnos      = todo[2];

    List<Alumno> verdes = new List();
    List<Alumno> rojos = new List();
    alumnos.forEach((alumno){
      if(alumno.estado) verdes.add(alumno);
      else rojos.add(alumno);
    });
    List<Alumno> aux = new List();
    verdes.forEach((v){
      aux.add(v);
    });
    rojos.forEach((r){
      aux.add(r);
    });
    alumnos = aux;

    asis = verdes.length;
    total = rojos.length;
    return Scaffold(
      appBar: AppBar(
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('$fecha'),
            Expanded(child: Container()),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('SI:$asis', style: TextStyle(fontSize: 15)),
                Text('NO:$total', style: TextStyle(fontSize: 15))
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: alumnos.length,
        itemBuilder: (context, index){
          return _cardAlumno(alumnos[index], alumnos[index].foto, context);
        },
      ),
    );
  }

  Widget _cardAlumno(Alumno alumno, String path, BuildContext context){
    return Column(
      children: <Widget>[
        Container(
          height: 110,
          padding: EdgeInsets.only(top: 10),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5.0,
            color: alumno.estado ? Colors.green : Colors.red,
            child: ListTile(
              leading: Container(
                width: 60.0,
                height: 60.0,
                child: path != "nada" && path != "null" ? Image.file(File(path)) : Icon(Icons.person)
              ),
              title: GestureDetector(
                onTap: (){
                  _masInfo(path, alumno.nombre, context);
                },
                child: Text(alumno.nombre, style: TextStyle(fontSize: 19))
              ),
              subtitle: Text(alumno.matricula, style: TextStyle(fontSize: 17))
            ),
          ),
        )
      ],
    );
  }

  _masInfo(String path, String nombre, BuildContext context){
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