import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:just_notify/model/client.dart';


class ClientScreen extends StatefulWidget {
  final Isar isar;
  const ClientScreen({super.key, required this.isar});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final clientFormKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController telephone = TextEditingController();

  //Create client
  Future<void> saveClient() async {

    final newClient = Client()..name = name.text ..telephone = telephone.text;

    await widget.isar.writeTxn(() async {
      await widget.isar.clients.put(newClient);
    });

    name.text = '';
    telephone.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Client"),
      ),
      body: Form(
        key: clientFormKey,
        child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextFormField(
                      controller: name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter client's name";
                        }
                      
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                        label: const Text("Client name"),
                        hintText: "Please enter client's name"
                      ),
                    ),
                  ),
                      
                   const SizedBox(height: 20,),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextFormField(
                      controller: telephone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter client's telephone";
                        }
                      
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                        label: const Text("Telephone number"),
                        hintText: "Please enter telephone number"
                      ),
                    ),
                  ),
                      
                  const SizedBox(height: 20,),
                      
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: OutlinedButton(
                      onPressed: () {
                        if (clientFormKey.currentState!.validate()) {
                          saveClient();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added")));
                        }
                        
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[100]
                      ), 
                      child: const Text("Submit", style: TextStyle(fontSize: 18),)
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }
}