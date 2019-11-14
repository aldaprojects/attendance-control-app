import 'dart:convert';

import 'package:asistencia/providers/db_provider.dart';
import 'package:asistencia/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:http/http.dart' as http;

import 'clases/alumno.dart';
import 'clases/asistencia.dart';
import 'clases/grupo.dart';


List<Asistencia> asistencias    = new List();
List<Alumno> alumnos            = new List();
List<Grupo> groups              = new List();

void crearObjetos(List<Alumno> alumnos, List<Asistencia> asistencias, List<Grupo> grupos){
  for(Alumno alumno in alumnos){
    for(Asistencia asistencia in asistencias){
      if(asistencia.idAlumno == alumno.idAlumno){
        alumno.estado = asistencia.estado == '0' ? false : true;
        break;
      }
    }
  }

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

  for(Grupo grupo in groups){
    for(Alumno alumno in alumnos){
      if(alumno.idGrupo == grupo.idGrupo){
        grupo.alumnos.add(alumno);
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var now = new DateTime.now();
  String fecha = '${now.year}-${now.month}-${now.day}';


  alumnos     = await DBProvider.db.getTodosAlumnos();
  asistencias = await DBProvider.db.getTodasAsistenciasbyFecha(fecha);
  groups      = await DBProvider.db.getTodosGrupos();

  if(asistencias.isEmpty){
    alumnos?.forEach((f){
      Asistencia asistencia = new Asistencia(
        idGrupo: f.idGrupo,
        fecha: fecha,
        idAlumno: f.idAlumno,
        estado: "0",
      );
      DBProvider.db.nuevaAsitenciaRam(asistencia);
    });
    asistencias = await DBProvider.db.getTodasAsistenciasbyFecha(fecha);
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.brown,
      ),
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: getRoutes(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState(){
    super.initState();
    getAsistencia();

  }

  getAsistencia() async {
    var now = new DateTime.now();
    String fecha = '${now.year}-${now.month}-${now.day}';
    asistencias = await DBProvider.db.getTodasAsistenciasbyFecha(fecha);
    crearObjetos(alumnos, asistencias, groups);
  }

  // TextEditingController _nombreGrupoController = new TextEditingController();
  var now = new DateTime.now();
  

  @override
  Widget build(BuildContext context) {
    String fecha = '${now.year}-${now.month}-${now.day}';
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mis Grupos')
      ),
      floatingActionButton: UnicornDialer(
        parentButtonBackground: Colors.brown,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.cloud),
        childButtons: _getButtons(),
      ),
      body: groups.length>0 ? ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index){
          if(groups.length>0){
            return _cardGrupo(groups[index], fecha);
          }
          else return Container();
        },
      ): 
      Center(
        child: Container(
          child: Text('No hay grupos', style: TextStyle(fontSize: 30)),
        ),
      ),
    );
  }


  List<UnicornButton> _getButtons(){

    List<UnicornButton> childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Cargar desde la web",
        currentButton: FloatingActionButton(
          heroTag: "btn2",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.web),
          onPressed: () {
            _cargarWeb();
          },
        )
      )
    );

    // childButtons.add(UnicornButton(
    //     hasLabel: true,
    //     labelText: "Subir a la web",
    //     currentButton: FloatingActionButton(
    //       heroTag: "btn1",
    //       backgroundColor: Colors.greenAccent,
    //       mini: true,
    //       child: Icon(Icons.group_add),
    //       onPressed: () {

    //       },
    //     )
    //   )
    // );

    return childButtons;
  }
  
  // _formularioCrearGrupo(){
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
  //                 child: Text('Nuevo Grupo')
  //               ),
  //               SizedBox(height: 20),
  //               TextField(
  //                 controller: _nombreGrupoController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Nombre del grupo',
  //                   hintText: 'Introduzca el nombre del grupo'
  //                 ),
  //               )
  //             ],
  //           )
  //         ),
          
  //         actions: <Widget>[
  //           FlatButton(
  //             child: Text('CREAR'),
  //             onPressed: (){
  //               final nombreGrupo = _nombreGrupoController.text;
  //               if(nombreGrupo.isEmpty){
  //                 showDialog(
  //                   context: context,
  //                   builder: (context){
  //                     return AlertDialog(
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
  //                       title: Center(
  //                         child: Column(
  //                           children: <Widget>[
  //                             Center(
  //                               child: Text('El nombre del grupo no debe estar vacío.')
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
  //                 Grupo nuevoGrupo = new Grupo(
  //                   nombre: nombreGrupo
  //                 );
  //                 DBProvider.db.nuevoGrupoRaw(nuevoGrupo);
  //                 Navigator.of(context).pop();
  //                 setState(() {groups.add(nuevoGrupo);});
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

  Widget _cardGrupo(Grupo grupo, String fecha){
    return Card(
      margin: EdgeInsets.only(top: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Text(grupo.nombre, style: TextStyle(fontSize: 30))
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('VER MAS', style: TextStyle(color: Colors.brown)),
                onPressed: () async {
                  List todo = new List();
                  todo.add(grupo);
                  todo.add(grupo.alumnos);
                  List<Asistencia> asistencias = await DBProvider.db.getTodasAsistenciasbyGrupo(
                    int.parse(grupo.idGrupo)
                  ); 
                  todo.add(asistencias);
                  Navigator.pushNamed(context, 'editarAlumnos', arguments: todo);}
              ),
              FlatButton(
                child: Text('PASAR LISTA', style: TextStyle(color: Colors.brown)),
                onPressed: () async {
                  Navigator.pushNamed(context, 'pasarLista', arguments: grupo.alumnos);
                },
              ),
            ],
          ),
        ],
        
      ),
    );
  }

  // _deleteGrupo(Grupo grupo){
  //   showDialog(
  //     context: context,
  //     builder: (context){
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
  //         title: Center(child: Text('¿Esta seguro que desea eliminar ${grupo.nombre}?')),
  //         elevation: 15,
  //         actions: <Widget>[
  //           Row(
  //             children: <Widget>[
  //               FlatButton(
  //                 child: Text('ELIMINAR'),
  //                 onPressed: (){setState(() {
  //                  DBProvider.db.deleteGrupo(int.parse(grupo.idGrupo));
  //                  groups.remove(grupo); 
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

  _cargarWeb(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Center(child: Text('¿Esta seguro que desea cargar los grupos desde la web?')),
          content: Text('Necesitará estar conectado a una red wifi o tener datos móviles. \nSe remplazarán los grupos actuales por los de la web.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: (){
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context){
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      title: Center(
                        child: Column(
                          children: <Widget>[
                            Text('Cargando...'),
                            Divider(),
                            FutureBuilder(
                              future: obtenerDB(),
                              builder: (BuildContext context,  AsyncSnapshot snapshot){
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
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
              }
            ),
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop()
            )
          ],
        );
      }
    );
  }
  
  Future<void> obtenerDB() async {

    var now = new DateTime.now();
    String fecha = '${now.year}-${now.month}-${now.day}';

    asistencias = await getAsistencias();
    alumnos     = await getAlumnos();
    groups      = await getGrupos();

    if(groups.length>0){
      await DBProvider.db.deleteGrupos();
      await DBProvider.db.deleteAsistencias();
      await DBProvider.db.deleteAlumnos();
    }

    asistencias.forEach((asistencia) async {
      await DBProvider.db.nuevaAsitenciaRam(asistencia);
    });

    alumnos.forEach((alumno) async {
      await DBProvider.db.nuevoAlumnoRaw(alumno);
    });

    groups.forEach((grupo) async {
      await DBProvider.db.nuevoGrupoRaw(grupo);
    });

    if(asistencias.isEmpty){
      alumnos?.forEach((f){
        Asistencia asistencia = new Asistencia(
          idGrupo: f.idGrupo,
          fecha: fecha,
          idAlumno: f.idAlumno,
          estado: "0",
        );
        DBProvider.db.nuevaAsitenciaRam(asistencia);
      });
      asistencias = await DBProvider.db.getTodasAsistenciasbyFecha(fecha);
    }
    setState(() {
      crearObjetos(alumnos, asistencias, groups);
    });
    Navigator.of(context).pop();
  }

  Future<List<Grupo>> getGrupos() async {
    List<Grupo> grupos = new List();
    final _grupos = await http.get('http://xhonane.com/control-asistencia/getdata.php');
    final List<dynamic> decodedData = json.decode(_grupos.body);
    
    decodedData.forEach((item){
      final Grupo grupo = new Grupo.fromJsonMap(item);
      grupos.add(grupo);
    });

    return grupos;
  }

  Future<List<Alumno>> getAlumnos() async {
    List<Alumno> alumnos = new List();
    final _alumnos = await http.post('http://xhonane.com/control-asistencia/getalumnos.php');
    final List<dynamic> decodedData = json.decode(_alumnos.body);

    decodedData.forEach((item){
      final Alumno alumno = new Alumno.fromJsonMap(item);
      alumnos.add(alumno);
    });

    return alumnos;
  }
  
  Future<List<Asistencia>> getAsistencias() async {
    List<Asistencia> asistencias = new List();
    final _asistencias = await http.post('http://xhonane.com/control-asistencia/getasistencia.php');
    final List<dynamic> decodedData = json.decode(_asistencias.body);

    decodedData.forEach((item){
      final Asistencia asistencia = new Asistencia.fromJsonMap(item);
      asistencias.add(asistencia);
    });

    return asistencias;
  }

}