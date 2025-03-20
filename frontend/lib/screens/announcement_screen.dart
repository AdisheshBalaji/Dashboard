import 'package:dashbaord/models/announcement_model.dart';
import 'package:dashbaord/widgets/announcement_card.dart';
import 'package:dashbaord/widgets/announcement_scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:go_router/go_router.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final ApiServices apiServices = ApiServices();
  List<String> _highlightedFilterOptions = ['All'];
  final List<String> _filterOptions = ['All', 'Unread', 'Important', 'More Filters...'];
  final List<String> tags = [
    'All',
    'Courses',
    'Admin',
    'Mess',
    'Scholarship',
    'ERP',
    'OCS',
    'Talks',
    'Transport',
    'Hostel Office',
    'Director',
    'Tag A',
    'Tag B',
    'Tag C',
    'Tag D',
  ];
  List<String> selectedTags = ['All'];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _bottomKey = GlobalKey();

  int _selectedChipIndex = 0;
  int _filterOptionChipIndex = 0;
  int limit = 10;
  int offset = 0;
  double _bottomHeight = 60.0;
  bool isSearching = false;
  bool isLoading = false;
  bool loadedAll = false;
  bool isFilterOpen = false;
  List<AnnouncementModel> announcements = [];

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> fetchAnnouncements() async {
    if (loadedAll) return;
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await ApiServices().getAnnouncements(limit, offset);
    final filters = await ApiServices().getAnnouncementsFilters();

    if (filters == null) {
      debugPrint('Error: Could not fetch filters');
    } else {
      _highlightedFilterOptions = filters;
    }

    if (response == null) {
      setState(() {
        loadedAll = true;
      });
      showError(msg: "You are at the end of list");
    } else {
      setState(() {
        announcements.addAll(response);
        offset += 10;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchAnnouncements();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
                autofocus: true,
              )
            : Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              size: 30.0,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            _bottomHeight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              return Column(
                key: _bottomKey,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 5, 8, 5),
                          child: Row(
                            children: List.generate(
                              _filterOptions.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected: _filterOptionChipIndex == index,
                                  label: Text(_filterOptions[index]),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _filterOptionChipIndex = selected ? index : 0;
                                    });
                                    _updateHeight();
                                  },
                                  selectedColor: const Color.fromRGBO(237, 90, 36, 1),
                                  showCheckmark: false,
                                  labelStyle: const TextStyle(color: Colors.white),
                                  backgroundColor: const Color.fromRGBO(48, 48, 48, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_filterOptionChipIndex == 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _highlightedFilterOptions.map((category) {
                              final isSelected =
                                  _selectedChipIndex == _highlightedFilterOptions.indexOf(category);
                              return FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedChipIndex ==
                                        _highlightedFilterOptions.indexOf(category);
                                  });
                                  _updateHeight();
                                },
                                backgroundColor: const Color(0xFF2A2A2A),
                                selectedColor: const Color(0xFFFF5722),
                                checkmarkColor: Colors.transparent,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ScrollConfiguration(
                            behavior: CustomScrollBehavior(),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tags.map((tag) {
                                    final isSelected = selectedTags.contains(tag);
                                    return FilterChip(
                                      label: Text(tag),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (tag == 'All') {
                                            selectedTags = ['All'];
                                          } else {
                                            selectedTags.remove('All');
                                            if (selected) {
                                              selectedTags.add(tag);
                                            } else {
                                              selectedTags.remove(tag);
                                            }
                                            if (selectedTags.isEmpty) {
                                              selectedTags = ['All'];
                                            }
                                          }
                                          _updateHeight();
                                        });
                                      },
                                      backgroundColor: const Color(0xFF2A2A2A),
                                      selectedColor: const Color(0xFFFF5722),
                                      checkmarkColor: Colors.transparent,
                                      showCheckmark: false,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _filterOptionChipIndex = 0;
                              });

                              _updateHeight();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFFFF5722),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length + 1,
        itemBuilder: (context, index) {
          if (index < announcements.length) {
            final announcement = announcements[index];
            if (_highlightedFilterOptions[_selectedChipIndex] != 'All') {
              if (!announcement.tags.contains(_highlightedFilterOptions[_selectedChipIndex])) {
                return const SizedBox.shrink();
              }
            }
            return AnnouncementCard(
                image: announcement.imageUrl,
                source: announcement.createdBy,
                date: announcement.createdAt.toString(),
                title: announcement.title,
                description: announcement.description,
                tags: announcement.tags);
          } else if (isLoading) {
            return Center(
              child: LoadingAnimationWidget.beat(
                color: Colors.blue,
                size: 50,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _updateHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _bottomKey.currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        setState(() {
          _bottomHeight = box.size.height;
        });
      }
    });
  }
}
