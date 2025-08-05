import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MessRegistrationScreen extends StatefulWidget {
  const MessRegistrationScreen({super.key});

  @override
  State<MessRegistrationScreen> createState() => _MessRegistrationScreenState();
}

class _MessRegistrationScreenState extends State<MessRegistrationScreen> {
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;

  Uri? currentUrl;

  final String userAgent =
      "Mozilla/5.0 (Linux; Android 11.0; Nexus 5 Build/MRA58N) "
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
    final isRootDiscourse =
        url == 'https://sva.iith.ac.in' || url == 'https://sva.iith.ac.in/';

    if (webViewController != null &&
        await webViewController!.canGoBack() &&
        !isRootDiscourse) {
      await webViewController!.goBack();
      return false;
    }

    return true;
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      android: AndroidInAppWebViewOptions(
    useHybridComposition: true,
  ));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Mess Registration'),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri("https://sva.iith.ac.in"),
                    ),
                    initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        userAgent: userAgent,
                        useOnLoadResource: true,
                        supportMultipleWindows: true),
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onCreateWindow: (controller, createWindowRequest) async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: InAppWebView(
                                windowId: createWindowRequest.windowId,
                                initialOptions: InAppWebViewGroupOptions(
                                  android: AndroidInAppWebViewOptions(
                                    builtInZoomControls: true,
                                    thirdPartyCookiesEnabled: true,
                                  ),
                                  crossPlatform: InAppWebViewOptions(
                                    cacheEnabled: true,
                                    javaScriptEnabled: true,
                                    userAgent: userAgent,
                                  ),
                                ),
                                onWebViewCreated:
                                    (InAppWebViewController controller) {},
                                onLoadStart: (InAppWebViewController controller,
                                    WebUri? url) {
                                  print("onLoadStart popup $url");
                                },
                                onLoadStop: (InAppWebViewController controller,
                                    WebUri? url) async {
                                  print("onLoadStop popup $url");
                                },
                                onCloseWindow: (controller) {
                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            
                          );
                        },
                      );

                      return true;
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
