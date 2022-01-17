import 'dart:io';

import 'package:delivery/models/category.dart';
import 'package:delivery/pages/restaurant/products/create/restaurant_products_create_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RestaurantProductsCreatePage extends StatefulWidget {
  @override
  _RestaurantProductsCreatePageState createState() => _RestaurantProductsCreatePageState();
}

class _RestaurantProductsCreatePageState extends State<RestaurantProductsCreatePage> {
  RestaurantProductsCreateController _con = RestaurantProductsCreateController();

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
        title: Text('Nuevo producto'),
      ),
      body: ListView(
        children: [
          _textFieldName(),
          _textFieldDescription(),
          _textFieldPrice(),
          Container(
            height: 100,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardImage(null, 1),
                _cardImage(null, 2),
                _cardImage(null, 3)
              ],
            ),
          ),
          _dropDownCategories([])
        ],
      ),
      bottomNavigationBar: _buttonCreate(),
    );
  }

  Widget _textFieldName(){
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.nameController,
        maxLines: 1,
        maxLength: 180,
        decoration: InputDecoration(
            hintText: 'Nombre del producto',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            suffixIcon: Icon(
                Icons.local_pizza,
                color: MyColors.primaryColor
            )
        ),
      ),
    );
  }

  Widget _textFieldDescription(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.descriptionController,
        maxLines: 3,
        maxLength: 255,
        decoration: InputDecoration(
            hintText: 'Descripcion del producto',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            suffixIcon: Icon(
                Icons.description,
                color: MyColors.primaryColor
            )
        ),
      ),
    );
  }

  Widget _textFieldPrice(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.priceController,
        keyboardType: TextInputType.phone,
        maxLines: 1,
        decoration: InputDecoration(
            hintText: 'Precio del producto',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            suffixIcon: Icon(
                Icons.monetization_on,
                color: MyColors.primaryColor
            )
        ),
      ),
    );
  }

  Widget _cardImage(File? imageFile, int numberFile){
    return imageFile != null
        ? Card(
          elevation: 3.0,
          child: Container(
            height: 140,
            width: MediaQuery.of(context).size.width * 0.2,
            child: Image.file(imageFile, fit: BoxFit.cover,),
          ),
        )
        : Card(
          elevation: 3.0,
          child: Container(
            height: 140,
            width: MediaQuery.of(context).size.width * 0.2,
            child: Image(image: AssetImage('assets/img/add_image.png'), fit: BoxFit.cover,),
          ),
        );
  }

  Widget _dropDownCategories(List<Category> categories){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 33),
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.search, color: MyColors.primaryColor,),
                  SizedBox(width: 15,),
                  Text('Categorias', style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey
                  ),)
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton<Category>(
                  hint: Text(
                    'Seleccionar categoria',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16
                    ),
                  ),
                  underline: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down_circle),
                    color: MyColors.primaryColor,
                  ),
                  elevation: 3,
                  isExpanded: true,
                  items: [],
                  onChanged: (Object? value) {

                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonCreate(){
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 30
      ),
      child: ElevatedButton(
        onPressed: _con.createProduct,
        child: Text('Crear producto'),
        style: ElevatedButton.styleFrom(
            primary: MyColors.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            padding: EdgeInsets.symmetric(vertical: 15)
        ),
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }
}
