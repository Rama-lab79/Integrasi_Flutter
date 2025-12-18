import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/item.dart';

class ApiService {
  // Untuk web, gunakan localhost
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Item> items = body.map((json) => Item.fromJson(json)).toList();
      return items;
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<Item> createItem(String name, String desc) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'description': desc}),
    );

    if (response.statusCode == 201) {
      return Item.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create item');
    }
  }

  static Future<void> updateItem(int id, String name, String desc) async {
    final response = await http.put(
      Uri.parse('$baseUrl/items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'description': desc}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  static Future<void> deleteItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/items/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }
}
