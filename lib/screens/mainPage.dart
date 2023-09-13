import 'package:flutter/material.dart';
import 'package:just_notify/screens/newClientScreen.dart';
import 'package:just_notify/model/client.dart';
import 'package:isar/isar.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  final Isar isar;
  const MainPage({super.key, required this.isar});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {

  List<Client> clients = [];
  List<String> phoneNumbers = [];
  PermissionStatus? smsStatus;

  void readClients() async {
    final getClients = await widget.isar.clients.where().findAll();

    setState(() {
      clients = getClients;
      populatePhoneList();
    });
  }

  void populatePhoneList() {
    phoneNumbers.clear();
    for(Client client in clients) {
      phoneNumbers.add(client.telephone!);
    }
  }

  void requestSMSPermission() async {
    final messenger = ScaffoldMessenger.of(context);
    smsStatus = await Permission.sms.request();

    if (smsStatus == PermissionStatus.denied) {
      messenger.showSnackBar(const SnackBar(content: Text("SMS permission is required")));
    }

    if(smsStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => requestSMSPermission());
    readClients();
  }

  Future<void> _sendSMS(String message, List<String> recipients) async {
    try {
      await sendSMS(message: message, recipients: recipients, sendDirect: true);
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    readClients();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),

      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      Client client = clients[index];
                      return ListTile(
                        title: Text(client.name!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async{
                                //final sms = await Permission.sms.request();
                                if (smsStatus == PermissionStatus.granted) {
                                  _sendSMS("You are ${index + 1} in line", [client.telephone!]);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message sent")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SMS permission is required")));
                                }
                              }, 
                              icon: const Icon(Icons.message) 
                            ),
          
                            IconButton(
                              onPressed: () async {
                                if (smsStatus == PermissionStatus.granted) {
                                  await widget.isar.writeTxn(() async {
                                    await widget.isar.clients.delete(client.id);
                                  });
                                  readClients();

                                  if (phoneNumbers.isNotEmpty) {
                                     _sendSMS("Hey ${client.name}, you are number ${index + 1} in line", phoneNumbers);
                                  }
                                 
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed successfully")));
                                } else {
                                  openAppSettings();
                                }
                              }, 
                              icon: const Icon(Icons.delete, color: Colors.red,)
                            )
                          ],
                        ),
                      );
                    }
                  ), 
                ),
                if (clients.isEmpty)
                  const Center(child: Text("No registered client"),)
              ],
            ),
          ),

          if (phoneNumbers.isNotEmpty)
            Expanded(
              flex: 1,
              child: Center(
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.isar.writeTxn(() async{
                      await widget.isar.clients.clear();
                    },
                    );
                    readClients();
                  },
                  child: const Text("Remove all", style: TextStyle(color: Color.fromARGB(255, 219, 64, 52)),)
                ),
              ) 
            )
        ],
      ),

      floatingActionButton: FloatingActionButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_) => ClientScreen(isar: widget.isar))), child: const Icon(Icons.add),),
    );
  }
}
