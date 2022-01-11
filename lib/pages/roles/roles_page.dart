import 'package:delivery/models/rol.dart';
import 'package:delivery/pages/roles/roles_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RolesPage extends StatefulWidget {
  @override
  _RolesPageState createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {

  RolesController _con = RolesController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona un rol')
      ),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.14),
        child: ListView(
          children: _con.user != null ? _con.user!.roles!.map((Rol rol) {
              print(rol.image);
              return _cardRol(rol);
            }).toList() : []
        ),
      ),
    );
  }

  Widget _cardRol(Rol rol){
    var rolImage;
    if(rol.image != null){
      rolImage = NetworkImage(rol.image!);
    } else {
      rolImage = AssetImage('assets/img/no-image.png');
    }

    return GestureDetector(
      onTap: () {
        _con.goToPage(rol.route!);
      },
      child: Column(
        children: [
          Container(
            height: 100,
            child: FadeInImage(
              image: rolImage,
              placeholder: AssetImage('assets/img/no-image.png'),
              fit: BoxFit.contain,
              fadeInDuration: Duration(
                milliseconds: 50
              ),
            )
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            rol.name ?? 'asdf',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black
            )
          ),
          SizedBox(
            height: 15
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
