import 'dart:convert';
import 'dart:io';
import 'package:image_downloader/image_downloader.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gplayer/gplayer.dart';

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
  var cameraRequest;
  var camerAnswer1;
  var camerAnswer2;
  var camerAnswer3;
  var camerAnswer4;
  var camerAnswer5;
  var url1 = "http://192.168.88.32:10080";
  var url2 = "http://192.168.88.15:8899";
  var url3 = "http://192.168.1.102:10080";
  var url4 = "http://192.168.0.104:8080";
  String mCreated;
  String mNonce;
  String mPasswordDigest;
  String mNewHeader;
  String getSnapshotUriAuth1;
  bool isAuth = false;
  Widget image;
  File file;
  Image camImage;
  String imagePath;

  String soapHeader = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
      "<soap:Envelope " +
      "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
      "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" " +
      "xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" >" +
      '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
          '<Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
          '<UsernameToken><Username>admin</Username>'
          '<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">'
          '8mdx0yoK22pKuN2NggG945oJZdA=</Password>'
          '<Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'
          'MTYyYTRmMzExYjBhMDE3Nw==</Nonce>'
          '<Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
          '2019-12-23T14:11:08Z</Created></UsernameToken></Security></v:Header>'
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
//          "PROFILE_000" +
          "001" +
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
  String mGetSnapshotUriAuth1;

  String otherOfficeCamera =
      '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
      'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
      '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
      '</v:Header><v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl"><ProfileToken>VideoIPCamera</ProfileToken></GetSnapshotUri></v:Body></v:Envelope>';

  String envelopEnd = "</soap:Body></soap:Envelope>";

  @override
  void initState() {
    _httpRequest(url4);
    // _mGetSnapshotUriAuth();
  }

  _image_dowlowder(var url) async {
    try {
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }

      // Below is a method of obtaining saved image information.
      var fileName = await ImageDownloader.findName(imageId);
      var path = await ImageDownloader.findPath(imageId);
      var size = await ImageDownloader.findByteSize(imageId);
      var mimeType = await ImageDownloader.findMimeType(imageId);
      print(fileName);
      print(path);
      print(size);
      print(mimeType);
    } catch (e) {
      print(e);
    }
  }

  _saveImageFromCam(List<int> urlImage) async {
    final output =
        await getExternalStorageDirectory(); // use the [path_provider (https://pub.dartlang.org/packages/path_provider) library:

    final file = File("${output.path}/camSnapshot.jpg");
    await file.writeAsBytes(urlImage);
    print(file.path);
    setState(() {
      camerAnswer1 = urlImage;
      imagePath = file.path;
    });
  }

  Future<void> _downloadFile(String url, String param) async {
//    File file;

    final response = await http.post(
      url,
      body: param,
    );

    _saveImageFromCam(response.bodyBytes);

    //print('ivan again');
//    File _file = new File('imageFromOfficeCamera.jpg');
//
//    await _file.writeAsByt`es(response.bodyBytes);
//    setState(() {
//      camImage = Image.file(_file);
//    });
  }

  _mGetSnapshotUriAuth() {
    String username = 'admin';
    mCreated = DateTime.now().toIso8601String().split('.')[0] + 'Z';
    mNonce = base64Encode(utf8.encode("1234567890"));
    String password = '123QWEasdZX';
    Digest mOnvifDigest =
        sha1.convert(utf8.encode('1234567890' + mCreated + '123QWEasdZXC'));
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

    mGetSnapshotUriAuth1 =
        '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" '
        'xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:v="http://www.w3.org/2003/05/soap-envelope">'
        '<v:Header><Action mustUnderstand="1" xmlns="http://www.w3.org/2005/08/addressing">http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri</Action>'
        '<v:Body><GetSnapshotUri xmlns="http://www.onvif.org/ver10/media/wsdl">'
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

//  headers: {"content-Type": "text/xml; charset=utf-8"}
  _httpRequest(String url) async {
    _mGetSnapshotUriAuth();
    var getDeviceBody = soapHeader + deviceInfoCommand + envelopEnd;
    var getProfileBody = soapHeader + profileCommand + envelopEnd;
    var getServicesBody = soapHeader + servicesCommand + envelopEnd;
//    final response = await http.post(url, body: mGetSnapshotUriAuth);
//    var response;
//      Future<http.Response> response = http.post('http://192.168.88.32:10080', body: mGetSnapshotUriAuth);
    var newUrlOtherCam =
        'http://192.168.88.15/webcapture.jpg?command=snap&channel=1&user=admin&password=wgEnjUi4';
//        'https://www.tenso-m.ru/f/catalog/products/336/1112-378x378.jpg';

      Future<http.Response> response = http.post(url4, body: otherOfficeCamera);
//    Future<http.Response> response =
//        http.post(newUrlOtherCam, body: otherOfficeCamera);
//    _downloadFile(newUrlOtherCam, otherOfficeCamera);
//    _saveImageFromCam(newUrlOtherCam)
    response.then((resp) {
      print(resp.body);
      setState(() => camerAnswer1 = resp.body);
    });
//      final responseStart = await http.post('http://192.168.88.32:10080', body: mGetStreamUriAuth);

//    setState(() {
//      camerAnswer1 = responseStart.body;
//      camerAnswer1 = "${responseStart.statusCode} ${_regexParser(responseStart.body, r'.*<s:Body>(.*)</s:Body>')}";
//    });
//      String url2 = 'http://192.168.88.32:14386/snapshot.cgi';
////      final response = await http.post('http://192.168.88.32:31229/snapshot.cgi', body: mGetSnapshotUriAuth);
//      http.Response response = await http.post(url2, body: mGetSnapshotUriAuth);
//                  print(response.statusCode);
//    setState(() {
//      camerAnswer2 = "${response.statusCode} \n${response.headers}\n \n${response.body}";
//      camerAnswer4 = """${response.body}""";
//    });
//            String nonce = _regexParser(response.headers.toString(), r'.*nonce=(.*)op.*');
//            String opaque= _regexParser(response.headers.toString(), r'.*opaque=(.*)lgo.*');
//            String realm = "goAhead";
//            String qop = "auth";
//            String nc = "00000001";
//            String cnonce = "1234567890";
//            String username = "admin";
//            String password = "123QWEasdZXC";
//            String uri = "/onvif/device_service";
//            print("nonce = $nonce");
//            print("opaque = $opaque");
//            print(response.headers);
//      //        setState(() => camerAnswer1 = _regexParser(response.headers.toString()));
//            Digest digest1 = md5.convert(utf8.encode("$username:$realm:$password"));
//            Digest digest2 = md5.convert(utf8.encode("POST:$uri"));
//            var _response = md5.convert(utf8.encode("$digest1:$nonce:$nc:$cnonce:$qop:$digest2"));
//            var mResponse = "Digest username=\"$username\", realm=\"$realm\", nonce=\"$nonce\", uri=\"$uri\",  qop=$qop, nc=$nc, cnonce=\"$cnonce\", response=\"$_response\"";
//            print(mResponse);
//            var mHeaders = {"Content-Type":"text/html", "Authorization": mResponse};
//            var mHeaders1 = {HttpHeaders.authorizationHeader:mResponse};
//            _downloadFile(url2, mHeaders, mGetSnapshotUriAuth);

//            http.Response response3 = await http.post(url2, headers: {"Content-Type":"text/html", "Authorization": mResponse}, body: "ivan");
//            print(response3.statusCode);
//            print(response3.body);
//    setState(() {
//      camerAnswer3 = "status code: ${response3.statusCode} \n header: ${response3.headers}\n \n body: ${response3.body}";
////      camerAnswer4 = """${response3.body}""";
//    });
//            http.Response response3 = await http.get(url2, headers: {"Content-Type":"text/html", "Authorization": mResponse});
    //Если меняем "Authorization" ================ломается
//            print(response3.body);
//    final newResponse = await http.post('http://192.168.88.32:10080', body: mGetSnapshotUriAuth);
  }

  String _regexParser(String msg, String pattern) {
    RegExp regExp = RegExp(pattern);
    String parsedMsg = regExp.firstMatch(msg)?.group(1);
    return parsedMsg.substring(1, parsedMsg.length - 3);
  }

  @override
  Widget build(BuildContext context) {
//    _httpRequest();

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("Ip camera"),
      ),
      body:
       SingleChildScrollView(child: SelectableText(camerAnswer1??""))
//      ListView(children: <Widget>[
//        camerAnswer1 != null
//            ? Image.memory(camerAnswer1)
//            : Container(
//                child: CircularProgressIndicator(),
//                width: 50,
//                height: 50,
//              ),
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Text(imagePath ?? ''),
//        ),
//        RaisedButton(
//          onPressed: () => _httpRequest(url1),
//          child: Text("get snapshot"),
//        )
//      ]),
    ));
  }
}
