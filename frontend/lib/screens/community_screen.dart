import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  InAppWebViewController? webViewController;

  final String userAgent =
      "Mozilla/5.0 (Linux; Android 11.0; IITH Dashboard Build/MRA58N) "
      "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'IITH Community',
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://discourse.iith.ac.in"),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent: userAgent,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }
}
