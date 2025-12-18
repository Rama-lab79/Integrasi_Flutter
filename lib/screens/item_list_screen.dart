import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late Future<List<Item>> _futureItems;
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _futureItems = ApiService.fetchItems();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRUD Items')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<List<Item>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _updateItem(context, item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item.id),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _addItem(BuildContext context) async {
    _nameController.clear();
    _descController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Add New Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Name"),
              controller: _nameController,
            ),
            TextField(
              decoration: InputDecoration(hintText: "Description"),
              controller: _descController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text.trim();
              String desc = _descController.text.trim();
              if (name.isNotEmpty) {
                await ApiService.createItem(name, desc);
                setState(() {
                  _futureItems = ApiService.fetchItems();
                });
                Navigator.of(context).pop();
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _updateItem(BuildContext context, Item item) async {
    _nameController.text = item.name;
    _descController.text = item.description;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Update Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController),
            TextField(controller: _descController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text.trim();
              String desc = _descController.text.trim();
              if (name.isNotEmpty) {
                await ApiService.updateItem(item.id, name, desc);
                setState(() {
                  _futureItems = ApiService.fetchItems();
                });
                Navigator.of(context).pop();
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int id) async {
    await ApiService.deleteItem(id);
    setState(() {
      _futureItems = ApiService.fetchItems();
    });
  }
}
