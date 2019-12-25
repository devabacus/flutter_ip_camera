import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http_auth/http_auth.dart' as auth;
import 'dart:math';
void main() => runApp(MyApp());

enum OnvifCommand {
  GetServices,
  GetDeviceInformation,
  GetProfiles,
  GetStreamURI
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String ipAddressCam1 = "192.168.88.32:10080";
  String ipAddressCam2 = "192.168.88.15:8899";
  String user = "admin";
  bool gotUrl = false;
  OnvifCommand state;
  var camerAnswer1;
  var camerAnswer2;
  var camerAnswer3;
  var camerAnswer4;
  var camerAnswer5;
  var url1 = "http://192.168.88.32:10080";
  var url2 = "http://192.168.88.15:8899";
  var url3 = "http://192.168.1.102:10080";
  String mCreated;
  String mNonce;
  String mPasswordDigest;
  String mNewHeader;
  String getSnapshotUriAuth1;

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

  String deviceInfoCommand =
      "<GetDeviceInformation xmlns=\"http://www.onvif.org/ver10/device/wsdl\">" +
          "</GetDeviceInformation>";

  String getSystemDateAndTime =
      "<GetSystemDateAndTime xmlns=\"http://www.onvif.org/ver10/device/wsdl\">" +
          "</GetSystemDateAndTime>";

  String profileCommand =
      "<GetProfiles xmlns=\"http://www.onvif.org/ver10/media/wsdl\"/>";
  String snapshotUri =
      "<GetSnapshotUri xmlns=\"http://www.onvif.org/ver20/media/wsdl\">"
          + "<ProfileToken>" + "PROFILE_000" + "</ProfileToken>"
          + "</GetSnapshotUri>";

  String streamUri =
      "<GetStreamUri xmlns=\"http://www.onvif.org/ver20/media/wsdl\">"
          + "<ProfileToken>" + "PROFILE_000" + "</ProfileToken>"
          + "<Protocol>RTSP</Protocol>"
          + "</GetStreamUri>";

  String homeGetSnapshotUriAuth = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
      'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
      '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
      '<Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
      '<UsernameToken><Username>admin</Username>'
      '<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">'
      '8mdx0yoK22pKuN2NggG945oJZdA=</Password>'
      '<Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'
      'MTYyYTRmMzExYjBhMDE3Nw==</Nonce>'
      '<Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
      '2019-12-23T14:11:08Z</Created></UsernameToken></Security></v:Header>'
      '<v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl">'
      '<ProfileToken>PROFILE_000</ProfileToken></GetSnapshotUri></v:Body></v:Envelope>';

  String officeGetSnapshotUriAuth;


  String otherOfficeCamera = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
      'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
      '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
      '</v:Header><v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl"><ProfileToken>000</ProfileToken></GetSnapshotUri></v:Body></v:Envelope>';


  String envelopEnd = "</soap:Body></soap:Envelope>";

  @override
  void initState() {
    _httpRequest(url3);
  // _mGetSnapshotUriAuth();
  }

   _mGetSnapshotUriAuth(){
    String username = 'admin';
    mCreated = DateTime.now().toIso8601String().split('.')[0] + 'Z';
     mNonce = base64Encode(utf8.encode("1234567890"));
    String password = '123QWEasdZXC';
    //home credentials
    String onvifCreated = '2019-12-23T14:11:08Z';
    String onvifNonce = 'MTYyYTRmMzExYjBhMDE3Nw==';
    String onvifPass = '8mdx0yoK22pKuN2NggG945oJZdA=';
     //office credentials
//    String onvifCreated = '2019-12-25T07:55:35.000Z';
//    String onvifNonce = 'Njg2YzYxZDI4YjA4ZDA0Nw==';
//    String onvifPass = 'x8IytKlr8cTH+sT9EzEaVDLqYGw=';
    Digest newDigest = md5.convert([]);
//    Digest mOnvifDigest = sha1.convert(utf8.encode(onvifCreated + onvifNonce + '123QWEasdZXC'));
    Digest mOnvifDigest = sha1.convert(utf8.encode('1234567890' + mCreated + '21063597'));

    mPasswordDigest = base64Encode(mOnvifDigest.bytes);
//    print(base64Encode(utf8.encode('a05e4b8113abb75e498f86e67e651d04927ae2ad')));
     print(mCreated);
     print(mNonce);
     print(mPasswordDigest);
//     print(base64Decode(onvifPass));
//     print(digest.bytes);
////    print('mCreated = $
// mCreated, mNonce = $mNonce, mPassDigest = $mPasswordDigest');
     onvifCreated = mCreated;
     onvifNonce = mNonce;
     onvifPass = mPasswordDigest;
     officeGetSnapshotUriAuth = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
         'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
         '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
         '<Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><UsernameToken><Username>admin</Username>'
         '<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">'
         '$onvifPass</Password>'
         '<Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'
         '$onvifNonce</Nonce><Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
         '$onvifCreated</Created></UsernameToken></Security></v:Header><v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl">'
         '<ProfileToken>PROFILE_000</ProfileToken></GetSnapshotUri></v:Body></v:Envelope>';
  }

  String _regexParser(String msg){
    RegExp regExp = RegExp(r".*<SOAP-ENV:Body>(.*)");
    var parsedMsg = regExp.firstMatch(msg).group(1);
    return parsedMsg;
  }

//  headers: {"content-Type": "text/xml; charset=utf-8"}
  _httpRequest(String url) async {
    String body1 = soapHeader + servicesCommand + envelopEnd;
    String body2 = soapHeader + getSystemDateAndTime + envelopEnd;
    String body3 = soapHeader + profileCommand + envelopEnd;
    String body4 = soapHeader + snapshotUri + envelopEnd;
    String body5 = soapHeader + streamUri + envelopEnd;
   // print(body1);
    var response2;
    var response3;
    var response4;
    var response5;
//    var response1 = await http.post(url, headers: {"Content-Type":"text/xml"}, body: body1);
    var client = DigestAuthClient("admin", "123QWEasdZXC");
//    var response1 = await client.post(url, headers: {"Content-Type":"text/xml"}, body: body4);
    _mGetSnapshotUriAuth();
    var response1 = await http.post(url, headers: {"Content-Type":"text/xml"}, body: officeGetSnapshotUriAuth);
    setState(() {
      camerAnswer1 = (response1.body);

    });
//    print("Response status: ${response1.statusCode}, Response body: ${response1.body}");
//    if(response1.statusCode == 200){
//      print(body2);
//
//      response2 = await http.post(url, headers: {"Content-Type":"text/xml; charset=utf-8"}, body: body2);
//      setState(() {
//        camerAnswer2 = (response2.body);
//      });
//    }
//    if(response2.statusCode == 200){
//      print(body3);
//      response3 = await http.post(url, body: body3);
//      setState(() {
//        camerAnswer3 = (response3.body);
//      });
//    }
//
//    if(response3.statusCode == 200){
//      print(body4);
//      response4 = await http.post(url, body: body4);
//     // var snapshotUri = await http.get('http://192.168.1.102:11230/snapshot.cgi');
////      var snapshotUri = await http.get('http://scale-driver.ru');
////      print(snapshotUri.statusCode);
//      setState(() {
//       camerAnswer4 = response4.body;
////       camerAnswer4 = "ivan";
//
//        gotUrl = true;
//      });

    //  print(snapshotUri.body);

//    }
//
//      print(body5);
//      response5 = await http.post(url, body: body5);
//      setState(() {
//        camerAnswer5 = response5.body;
//      });
  }

  @override
  Widget build(BuildContext context) {
//    _httpRequest();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Ip camera"),
        ),
//        body: SingleChildScrollView(child: Text(camerAnswer.toString())),
      body:
      ListView(children: <Widget>[
        SelectableText(camerAnswer1.toString()),
        SizedBox(height: 30,),
//        Text(camerAnswer2.toString()),
//        SizedBox(height: 30,),
//        Text(camerAnswer3.toString()),
//        SizedBox(height: 30,),
//        Text(camerAnswer4.toString()),
//        SizedBox(height: 30,),
//        Text(camerAnswer5.toString())
      ],),
      ),
    );
  }
}
