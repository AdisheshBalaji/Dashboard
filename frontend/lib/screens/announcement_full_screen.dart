import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/utils/format_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementFullScreen extends StatefulWidget {
  final String? image;
  final String source;
  final String date;
  final String title;
  final String description;
  final List<String> tags;
  final num id;

  const AnnouncementFullScreen(
      {super.key,
      required this.image,
      required this.source,
      required this.date,
      required this.title,
      required this.description,
      required this.tags,
      required this.id});

  @override
  State<AnnouncementFullScreen> createState() => _AnnouncementFullScreenState();
}

class _AnnouncementFullScreenState extends State<AnnouncementFullScreen> {
  final ApiServices apiServices = ApiServices();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ApiServices apiServices = ApiServices();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: context.customColors.customAccentColor,
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          centerTitle: true,
          leadingWidth: 20,
          title: Text(
            widget.source,
            style: GoogleFonts.outfit(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              height: 60,
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Row(
                            children: [
                              Text(
                                formatDate(int.parse(widget.date)),
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        "${apiServices.backendUrl}${widget.image}",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "${apiServices.backendUrl}${widget.image}",
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                MarkdownBody(
                  data: widget.description,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    h1: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    h2: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    h3: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ));
  }
}
