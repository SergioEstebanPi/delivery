import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Image.asset(
              'assets/img/delivery.png',
              width: 200,
              height: 200,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Correo electronico'
              ),
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Contraseña'
              ),
            ),
            ElevatedButton(
                onPressed: () {

                }, child: Text('INGRESAR')
            ),
            Row(
              children: [
                Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(
                      color: MyColors.primaryColor
                  ),
                ),
                SizedBox(width: 7,),
                Text(
                  'Registrate',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MyColors.primaryColor
                  ),
                )
              ],
            )
          ]
        ),
      )
    );
  }
}
