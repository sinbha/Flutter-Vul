import 'dart:io';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

///Class that defines a category
class Categories with ChangeNotifier{
  Map<String, String> _categories = {};

  Map<int, String> get categories{
    return Map.from(_categories);
  }

  ///Gets data from the server about all categories
  ///Throws [HttpException] for generic server and database errors
  Future<Map<String, String>> getCategoriesFromServer() async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'categories': 'all'});
    final Map<String, String> categories = {};
    final extractedData = json.decode(response.body) as List<dynamic>;
    if(extractedData.isEmpty) return categories;
    for (var categoryData in extractedData) {
      categories[categoryData['idCategory']] = categoryData['name'];
    }
    _categories = categories;
    return categories;
  }

  ///Creates a [Category]
  ///Throws [HttpException] for generic server and database errors
  Future<void> createCategory(String adminId, String name) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'createCategory': adminId, 'name': name});
      if(response.statusCode != 200) {
        throw HttpException;
      }
    }catch(error){
      rethrow;
    }
  }

  ///Deletes a [Category]
  ///Throws [HttpException] for generic server and database errors
  Future<void> deleteCategory(String adminId, String categoryId) async {
    categories.remove(categoryId);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.post(url, headers: {'removeCategory': adminId, 'categoryId': categoryId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
  }

}