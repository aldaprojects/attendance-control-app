import 'dart:async';
import 'dart:io';


import 'package:asistencia/clases/alumno.dart';
import 'package:asistencia/clases/asistencia.dart';
import 'package:asistencia/providers/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';



class PasarLista extends StatefulWidget {
  @override
  _PasarListaState createState() => _PasarListaState();
}

class _PasarListaState extends State<PasarLista> {



  

  List<Alumno> alumnos;

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  
  bool isDiscovering = false;



  void _startDiscovery() async {
    isDiscovering = true;
    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() { 
        alumnos.forEach((alumno){
          if(alumno.mac == r.device.address || alumno.matricula == r.device.name){
            alumno.estado = true;
            if(alumno.mac != r.device.address){
              DBProvider.db.updateMac(r.device.address, int.parse(alumno.idAlumno));
            }
          }
        });
      });
    });

    _streamSubscription.onDone(() {
      setState(() { isDiscovering = false; });
    });
  }
  int total = 0;
  int asis  = 0;

  @override
  Widget build(BuildContext context) {

    alumnos = ModalRoute.of(context).settings.arguments;
    alumnos.forEach((a){
      print('${a.nombre} ${a.mac}');
    });
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
    

    var now = new DateTime.now();
    String today = '${now.day}-${now.month}-${now.year}';
    String fecha = '${now.year}-${now.month}-${now.day}';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Stack(
          children: <Widget>[
            Center(child: Text('$today')),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
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
          ]
        ),
        actions: <Widget>[
          _subirInfo(alumnos, fecha),
          _bluetooth()

        ],
      ),
      body: alumnos.length > 0 ? ListView.builder(
        itemCount: alumnos.length,
        itemBuilder: (BuildContext context, int index){
          return _cardAlumno(alumnos[index], alumnos[index].foto);
        },
      ) : Center(child: Text('No hay alumnos', style: TextStyle(fontSize: 25))),
      
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
            color: alumno.estado ? Colors.green : Colors.red,
            child: ListTile(
              leading: Container(
                width: 60.0,
                height: 60.0,
                child: path != "nada" && path != "null" ? Image.file(File(path)) : Icon(Icons.person)
              ),
              title: GestureDetector(
                onTap: (){
                  _masInfo(path, alumno.nombre);
                },
                child: Text(alumno.nombre, style: TextStyle(fontSize: 19))
              ),
              subtitle: Text(alumno.matricula, style: TextStyle(fontSize: 17)),
              trailing: Checkbox(
                value: alumno.estado,
                onChanged: (bool value){
                  setState(() {
                    alumno.estado = value;
                  });
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  _subirInfoDB(List<Alumno> alumnos, String fecha){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Center(
            child: Column(
              children: <Widget>[
                Text('Subiendo...'),
                Divider(),
                CircularProgressIndicator()
              ],
            )
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop()
            )
          ],
        );
      }
    );
    alumnos.forEach((a){
      DBProvider.db.updateAsistencia(Asistencia(
        estado: a.estado ? "1":"0",
        fecha: fecha,
        idAlumno: a.idAlumno,
        idGrupo: a.idGrupo
      ));
    });
    Navigator.of(context).pop();
  }

  Widget _subirInfo(List<Alumno> alumnos, String fecha){
    return IconButton(
      icon: Icon(Icons.done),
      onPressed: (){
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: Center(child: Text('Advertencia')),
              content: Text('¿Realmente quiere guardar los cambios? Estos se verán reflejados en la base de datos.'),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop()
                ),
                FlatButton(
                  child: Text('OK'),
                  onPressed: (){
                    Navigator.of(context).pop();
                    _subirInfoDB(alumnos, fecha);
                  }
                ),
              ],
            );
          }
        );
      },
    );

  }

  Widget _bluetooth(){
    return IconButton(
      icon: isDiscovering 
            ? FittedBox(child: Container(
                margin: new EdgeInsets.all(16.0),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              ))
            :
            Icon(Icons.bluetooth),
      onPressed: () async {   
        await FlutterBluetoothSerial.instance.requestEnable();
         if(!isDiscovering)
        _startDiscovery();
        setState(() {
        });
      },
    );
  }

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