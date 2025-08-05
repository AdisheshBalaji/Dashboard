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
  late PullToRefreshController pullToRefreshController;

  Uri? currentUrl;

  final String userAgent =
      "Mozilla/5.0 (Linux; Android 11.0; IITH Dashboard Build/MRA58N) "
      "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36";

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        await webViewController?.reload();
      },
    );
  }

  Future<bool> _onWillPop() async {
    final url = currentUrl?.toString() ?? '';
    final isRootDiscourse = url == 'https://discourse.iith.ac.in' ||
        url == 'https://discourse.iith.ac.in/';

    if (webViewController != null &&
        await webViewController!.canGoBack() &&
        !isRootDiscourse) {
      await webViewController!.goBack();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'IITH Community'),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri("https://discourse.iith.ac.in"),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      userAgent: userAgent,
                    ),
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        currentUrl = url;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
