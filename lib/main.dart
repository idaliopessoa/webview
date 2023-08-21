import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  await Permission.microphone.request();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor:
        Color.fromRGBO(9, 142, 197, 1), // navigation bar color
    statusBarColor: Color.fromRGBO(9, 142, 197, 1), // status bar color
  ));
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InAppWebViewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({super.key});

  @override
  InAppWebViewPageState createState() => InAppWebViewPageState();
}

class InAppWebViewPageState extends State<InAppWebViewPage> {
  // ignore: unused_field
  InAppWebViewController? _webViewController;
  final initalUrl = URLRequest(
      url: Uri.parse(
          "https://app-test2.certfy.tech/onboarding/autoid/fe4ef559-6c9e-4210-b7ae-6c80ece759ef/steps"));
  final urlController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: <Widget>[
        TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
          controller: urlController,
          keyboardType: TextInputType.text,
          onSubmitted: (value) {
            var url = Uri.parse(value);
            if (url.scheme.isEmpty) {
              url = Uri.parse(("https://www.google.com/search?q=") + value);
            }
            _webViewController?.loadUrl(urlRequest: URLRequest(url: url));
          },
        ),
        Expanded(
          child: InAppWebView(
              initialUrlRequest: initalUrl,
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              androidOnPermissionRequest: (InAppWebViewController controller,
                  String origin, List<String> resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              }),
        ),
      ]),
    ));
  }
}
