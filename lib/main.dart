import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';

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
  bool isAuth = false;

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
      "<GetSnapshotUri xmlns=\"http://www.onvif.org/ver20/media/wsdl\">" +
          "<ProfileToken>" +
          "PROFILE_000" +
          "</ProfileToken>" +
          "</GetSnapshotUri>";

  String streamUri =
      "<GetStreamUri xmlns=\"http://www.onvif.org/ver20/media/wsdl\">" +
          "<ProfileToken>" +
          "PROFILE_000" +
          "</ProfileToken>" +
          "<Protocol>RTSP</Protocol>" +
          "</GetStreamUri>";

  String homeGetSnapshotUriAuth =
      '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
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

  String mGetSnapshotUriAuth;
  String mGetStreamUriAuth;

  String otherOfficeCamera =
      '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
      'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
      '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
      '</v:Header><v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl"><ProfileToken>000</ProfileToken></GetSnapshotUri></v:Body></v:Envelope>';

  String envelopEnd = "</soap:Body></soap:Envelope>";

  @override
  void initState() {
    _httpRequest(url3);
    // _mGetSnapshotUriAuth();
  }

  _mGetSnapshotUriAuth() {
    String username = 'admin';
    mCreated = DateTime.now().toIso8601String().split('.')[0] + 'Z';
    mNonce = base64Encode(utf8.encode("1234567890"));
    String password = '123QWEasdZXC';
    Digest mOnvifDigest =
        sha1.convert(utf8.encode('1234567890' + mCreated + '21063598'));
    mPasswordDigest = base64Encode(mOnvifDigest.bytes);
    mGetSnapshotUriAuth =
        '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
        'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
        '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
        '<Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><UsernameToken><Username>admin</Username>'
        '<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">'
        '$mPasswordDigest</Password>'
        '<Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'
        '$mNonce</Nonce><Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
        '$mCreated</Created></UsernameToken></Security></v:Header><v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl">'
        '<ProfileToken>PROFILE_000</ProfileToken></GetSnapshotUri></v:Body></v:Envelope>';


    mGetStreamUriAuth =
    '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
        'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
        '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
        '<Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><UsernameToken><Username>admin</Username>'
        '<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">'
        '$mPasswordDigest</Password>'
        '<Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'
        '$mNonce</Nonce><Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
        '$mCreated</Created></UsernameToken></Security></v:Header><v:Body><GetStreamUri xmlns="http://www.onvif.org/ver10/media/wsdl">'
        '<ProfileToken>PROFILE_000</ProfileToken><Protocol>RTSP</Protocol></GetStreamUri></v:Body></v:Envelope>';
  }

  String _regexParser(String msg) {
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
    _mGetSnapshotUriAuth();
    var response1 = await http.post(url,
        headers: {"Content-Type": "text/xml"}, body: mGetStreamUriAuth);

    setState(() {
      camerAnswer1 = (response1.body);
      isAuth = true;
    });

//    var response10 = await http.get('http://192.168.1.102:23203/snapshot.cgi');
//    print(response10.statusCode);

//    var imageId = await ImageDownloader.downloadImage(
//        'http://192.168.1.102:13237/snapshot.cgi?user=admin&pwd=21063598&res=0');
////    http://192.168.1.102:23203/snapshot.cgi?user=admin&pwd=123QWEasdZXC&res=0
////    'https://www.tenso-m.ru/f/catalog/products/22/979.jpg');
//    if (imageId == null) {
//      return;
//    }
//    var fileName = await ImageDownloader.findName(imageId);
//    var path = await ImageDownloader.findPath(imageId);
//    var size = await ImageDownloader.findByteSize(imageId);
//    var mimeType = await ImageDownloader.findMimeType(imageId);
//    print(fileName);
//    print(path);
//    print(size);
//    print(mimeType);
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
//          CachedNetworkImage(
//            imageUrl: "https://www.tenso-m.ru/f/catalog/products/22/979.jpg",
//            placeholder: (context, url) => CircularProgressIndicator(),
//            errorWidget: (context, url, error) => Icon(Icons.error),
//          ),

//      ListView(children: <Widget>[
//              Container(
//                  width: 400,
//                  height: 400,
//                  child: isAuth
//                      ? Image.network(
//                          'http://192.168.1.102:13237/snapshot.cgi')
////                          'http://192.168.1.102:13237/snapshot.cgi?user=admin&pwd=21063598&res=0')
////                          'https://www.tenso-m.ru/f/catalog/products/22/979.jpg')
//                      : Container(
//                          width: 400,
//                          height: 400,
//                          color: Colors.lightBlue,
//                        ))
        SelectableText(camerAnswer1.toString()),
//        NetworkImage('http://192.168.1.102:23203/snapshot.cgi?user=admin&pwd=123QWEasdZXC&res=0')
//      ],),
          ),
    );
  }
}
