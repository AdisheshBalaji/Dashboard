import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnouncementCard extends StatelessWidget {
  AnnouncementCard(
      {super.key,
      required this.image,
      required this.source,
      required this.date,
      required this.title,
      required this.description,
      required this.tags,
      required this.id});

  final String? image;
  final String source;
  final String date;
  final String title;
  final String description;
  final List<String> tags;
  final num id;

  final ApiServices _apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/announcements/$id',
          extra: {
            'image': image,
            'source': source,
            'date': date,
            'title': title,
            'description': description,
            'tags': tags,
            'id': id,
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? Color.fromRGBO(41, 41, 41, 1)
            : Color.fromRGBO(255, 255, 255, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  '${_apiServices.backendUrl}$image',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color.fromRGBO(48, 48, 48, 1)
                        : Color.fromRGBO(255, 255, 255, 1),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                source,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.headlineLarge!.color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                formatDate(int.parse(date)),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: tags.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, idx) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          tags[idx],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headlineLarge!.color,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (description.length > 200)
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(bounds),
                            blendMode: BlendMode.dstIn,
                            child: Text(
                              '${description.substring(0, 200)}...',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        else
                          Text(
                            description,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium!.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
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
