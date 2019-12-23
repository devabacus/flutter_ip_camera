import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String ipAddressCam1 = "192.168.88.32:10080";
  String ipAddressCam2 = "192.168.88.15:8899";
  String user = "admin";

  String soapHeader = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
      "<soap:Envelope " +
      "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
      "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" " +
      "xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" >" +
      "<soap:Body>";

  String servicesCommand =
      "<GetServices xmlns=\"http://www.onvif.org/ver10/device/wsdl\">" +
          "<IncludeCapability>false</IncludeCapability>" +
          "</GetServices>";

  String envelopEnd = "</soap:Body></soap:Envelope>";


  @override
  void initState() {
    _httpRequest();
  }
//  headers: {"content-Type": "text/xml; charset=utf-8"}
  _httpRequest() async {
    var url = "http://$ipAddressCam2";
    String body1 = soapHeader + servicesCommand + envelopEnd;
    print(body1);
    var response = await http.post(url, body: body1);
    print("Response status: ${response.statusCode}, Response body: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
//    _httpRequest();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Ip camera"),
        ),
      ),
    );
  }
}
