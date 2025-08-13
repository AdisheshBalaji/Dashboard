import 'package:dashbaord/constants/building_data.dart';
import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/utils/mesaure_size.dart';
import 'package:dashbaord/widgets/campus_map/building_info.dart';
import 'package:dashbaord/widgets/campus_map/location_indicator.dart';
import 'package:dashbaord/widgets/campus_map/map_search_overlay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  bool isLoading = true;
  bool showBusRoutes = false;
  bool showLegend = false;
  bool showSearch = false;
  double currentScale = 1.0;
  double inverseScale = 1.0;
  double markerWidth = 15;
  double markerHeight = 15;
  double? mapWidth;
  double? mapHeight;
  Offset? gpsOffset;
  Position? currentPosition;
  late TransformationController _transformationController;
  final TextEditingController _searchController = TextEditingController();
  List<BuildingType> searchResults = [];
  BuildingType? highlightedBuilding;
  final GlobalKey _mapKey = GlobalKey();
  final markerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });

    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), _updateSvgSize);
      _updateSvgSize();
    });
    _initGPS();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSvgSize() {
    final renderBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      debugPrint("SVG Rendered Size: ${size.width} x ${size.height}");
      setState(() {
        mapWidth = size.width;
        mapHeight = size.height;
      });
    }
  }


  Future<void> _initGPS() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError(
          "Location services are disabled. Please enable GPS.",
          showSettingsButton: true,
          onSettingsPressed: () async {
            await Geolocator.openLocationSettings();
          },
        );
        return;
      }
  
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError(
            "Location permission denied. Please allow location access.",
            showSettingsButton: true,
            onSettingsPressed: () async {
              await AppSettings.openAppSettings();
            },
          );
          return;
        }
      }
  
      if (permission == LocationPermission.deniedForever) {
        _showError(
          "Location permission is permanently denied. Please enable it in app settings.",
          showSettingsButton: true,
          onSettingsPressed: () async {
            await AppSettings.openAppSettings();
          },
        );
        return;
      }
  
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
  
      debugPrint('Current Location: ${currentPosition.toString()}');
      _updateGPSMarker();
    } catch (e, stack) {
      debugPrint("GPS init error: $e\n$stack");
      _showError("Failed to retrieve location. Please try again.");
    }
  }
  
  void _showError(String message,
        {bool showSettingsButton = false, VoidCallback? onSettingsPressed}) {
      ScaffoldMessenger.of(context).clearSnackBars();
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          action: showSettingsButton
              ? SnackBarAction(
                  label: "Settings",
                  textColor: Theme.of(context).colorScheme.onErrorContainer,
                  onPressed: onSettingsPressed ?? () {},
                )
              : null,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
     
  void _updateGPSMarker() {
    if (currentPosition == null) return;
    // For debugging (Improving Accuracy)
    // EV Circle
    // 17.59659, 78.12524
    // 484, 540
    //
    // UB Desai Circle
    // 17.58776, 78.12110
    // 296, 957
    //
    // delta_lat = 0.00883/188
    // delta_long = 0.00414/-417
    //
    // 17.5738574468, 78.1306011511
    // 17.6364189362, 78.1168210072 (Initial)
    // 17.6134985106, 78.1182341007 (Second Version)
    // actual values work well with bhabha

    const double minLat = 17.5738574468;
    const double maxLat = 17.6155985106;
    const double minLon = 78.1170341007;
    const double maxLon = 78.1306011511;

    if (mapWidth == null || mapHeight == null) {
      return;
    }

    double x =
        ((currentPosition!.longitude - minLon) / (maxLon - minLon)) * mapWidth!;
    double y =
        ((maxLat - currentPosition!.latitude) / (maxLat - minLat)) * mapHeight!;

    x = x.clamp(0.0, mapWidth!);
    y = y.clamp(0.0, mapHeight!);

    debugPrint(
        'GPS: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
    debugPrint('Pixel: x=$x, y=$y');
    debugPrint('Bounds check: x in [0,$mapWidth], y in [0,$mapHeight]');

    bool latInBounds = currentPosition!.latitude >= minLat &&
        currentPosition!.latitude <= maxLat;
    bool lonInBounds = currentPosition!.longitude >= minLon &&
        currentPosition!.longitude <= maxLon;

    if (!latInBounds || !lonInBounds) {
      debugPrint('WARNING: GPS coordinates are outside map bounds!');
      debugPrint('Lat in bounds: $latInBounds, Lon in bounds: $lonInBounds');
      return;
    }

    setState(() {
      gpsOffset = Offset(x, y);
    });

    debugPrint("GPS OFFSET UPDATED: ${gpsOffset}");
  }

  void _onTransformationChanged() {
    setState(() {
      currentScale = _transformationController.value.getMaxScaleOnAxis();
      inverseScale = 1 / currentScale;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      searchResults = buildingData.entries
          .where((entry) {
            final building = entry.value;
            final nameMatch = building.name.toLowerCase().contains(query);
            final descMatch =
                building.description.toLowerCase().contains(query);
            final tagMatch =
                building.tags.any((tag) => tag.toLowerCase().contains(query));

            final nameWords = building.name.toLowerCase().split(' ');
            final queryWords = query.split(' ');
            final fuzzyNameMatch = queryWords.any((queryWord) => nameWords.any(
                (nameWord) =>
                    nameWord.startsWith(queryWord) ||
                    _calculateSimilarity(queryWord, nameWord) > 0.7));

            return nameMatch || descMatch || tagMatch || fuzzyNameMatch;
          })
          .map((entry) => entry.key)
          .toList();

      searchResults.sort((a, b) {
        final aBuilding = buildingData[a]!;
        final bBuilding = buildingData[b]!;

        final aExact = aBuilding.name.toLowerCase().contains(query) ? 1 : 0;
        final bExact = bBuilding.name.toLowerCase().contains(query) ? 1 : 0;

        if (aExact != bExact) return bExact.compareTo(aExact);

        final aStarts = aBuilding.name.toLowerCase().startsWith(query) ? 1 : 0;
        final bStarts = bBuilding.name.toLowerCase().startsWith(query) ? 1 : 0;

        return bStarts.compareTo(aStarts);
      });

      highlightedBuilding = null;
    });
  }

  double _calculateSimilarity(String str1, String str2) {
    if (str1.length < 2 || str2.length < 2) return 0.0;

    int matches = 0;
    int minLength = str1.length < str2.length ? str1.length : str2.length;

    for (int i = 0; i < minLength; i++) {
      if (str1[i] == str2[i]) matches++;
    }

    return matches / (str1.length > str2.length ? str1.length : str2.length);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _showBlockDetails(BuildingType type) {
    final building = buildingData[type];

    if (building != null) {
      BlockDetailsModal.show(
        context,
        blockName: building.name,
        description: building.description,
        tags: building.tags,
        latitude: building.latitude,
        longitude: building.longitude,
        mapLink: building.mapLink,
      );
    } else {
      debugPrint("No data found for $type");
    }
  }

  void _selectSearchResult(BuildingType buildingType) {
    setState(() {
      highlightedBuilding = buildingType;
      showSearch = false;
      _searchController.clear();
      searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CustomLoadingScreen()
        : Scaffold(
            appBar: const CustomAppBar(title: 'Campus Map'),
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 8,
                      boundaryMargin: const EdgeInsets.all(100),
                      child: Stack(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(animation),
                                child: FadeTransition(
                                    opacity: animation, child: child),
                              );
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const aspectRatio = 848 / 1405;
                                double renderWidth = constraints.maxWidth;
                                double renderHeight = renderWidth / aspectRatio;
                                debugPrint("RENDERED $renderWidth x $renderHeight");
                                if (renderHeight > constraints.maxHeight) {
                                  renderHeight = constraints.maxHeight;
                                  renderWidth = renderHeight * aspectRatio;
                                }
                                if (mapWidth != renderWidth ||
                                    mapHeight != renderHeight) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    setState(() {
                                      mapWidth = renderWidth;
                                      mapHeight = renderHeight;
                                    });
                                  });
                                }

                                return Center(
                                  child: SizedBox(
                                    width: renderWidth,
                                    height: renderHeight,
                                    child: SvgPicture.asset(
                                      showBusRoutes
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 'assets/images/campus_map_dark_with_route.svg'
                                              : 'assets/images/campus_map_light_with_route.svg')
                                          : (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 'assets/images/campus_map_dark.svg'
                                              : 'assets/images/campus_map_light.svg'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (gpsOffset != null && !showSearch)
                            LocationIndicator(
                              gpsOffset: gpsOffset ?? Offset(0, 0),
                              type: LocationIndicatorType.pulsing,
                              color: context.customColors.customAccentColor,
                            ),
                          if (highlightedBuilding != null)
                            Positioned(
                              left: highlightedBuilding!.left +
                                  highlightedBuilding!.width / 2 -
                                  (markerWidth / 10),
                              top: highlightedBuilding!.top +
                                  highlightedBuilding!.height / 2 -
                                  (markerHeight / 2),
                              child: GestureDetector(
                                onTap: () {
                                  _showBlockDetails(highlightedBuilding!);
                                },
                                child: MeasureSize(
                                  onChange: (Size newSize) {
                                    setState(() {
                                      markerWidth = newSize.width;
                                      markerHeight = newSize.height;
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.redAccent,
                                        size: 25 * inverseScale,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2 * inverseScale,
                                          vertical: 2 * inverseScale,
                                        ),
                                        constraints: BoxConstraints(
                                            maxWidth: 150 * inverseScale),
                                        child: Text(
                                          buildingData[highlightedBuilding]!
                                              .name,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .displayLarge
                                                ?.color,
                                            fontSize: 15 * inverseScale,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ...BuildingType.values.map((type) {
                            return Positioned(
                              top: (type.top / 596.4622641509434) *
                                  (mapHeight ?? 596.4622641509434),
                              left: (type.left / 360) * (mapWidth ?? 360),
                              child: GestureDetector(
                                onTap: () => _showBlockDetails(type),
                                child: Container(
                                  width: type.width,
                                  height: type.height,
                                  decoration: BoxDecoration(
                                      // Change null to building name to highlight during development
                                      color: (type == null
                                          ? Colors.red
                                          : Colors.transparent),
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 2,
                                      )),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  if (showSearch)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: SearchOverlay(
                            searchController: _searchController,
                            showSearch: showSearch,
                            searchResults: searchResults,
                            buildingData: buildingData,
                            onClose: () {
                              setState(() {
                                showSearch = false;
                                _searchController.clear();
                                searchResults = [];
                                highlightedBuilding = null;
                              });
                            },
                            onResultTap: (buildingType) =>
                                _selectSearchResult(buildingType),
                          ),
                        ),
                      ),
                    ),
                  if (!showSearch) ...[
                    Positioned(
                      left: 16,
                      top: 16,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Tap ",
                              style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            TextSpan(
                              text: "any landmark\n to see details",
                              style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Image.asset(
                        'assets/images/north_indicator.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 70,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showSearch = true;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.customColors.customAccentColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.customColors.customContainerColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: context.customColors.customShadowColor,
                              offset: const Offset(0, 2),
                              blurRadius: 12.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              showBusRoutes = !showBusRoutes;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  'Bus Routes',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  '  |  ',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  showBusRoutes ? "On" : "Off",
                                  style: GoogleFonts.inter(
                                    color: showBusRoutes
                                        ? context.customColors.customAccentColor
                                        : Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 70,
                      child: GestureDetector(
                        onTap: () {
                          _initGPS();
                          _updateGPSMarker();
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: const Text('Area 52'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Map Size:'),
                                      Text(
                                          'Width: ${mapWidth?.toStringAsFixed(2) ?? "?"}'),
                                      Text(
                                          'Height: ${mapHeight?.toStringAsFixed(2) ?? "?"}'),
                                      const SizedBox(height: 12),
                                      Text('Current Location:'),
                                      Text(
                                        currentPosition != null
                                            ? 'Lat: ${currentPosition!.latitude}\nLon: ${currentPosition!.longitude}'
                                            : 'No GPS data',
                                      ),
                                      const SizedBox(height: 12),
                                      Text('Pixel Offset:'),
                                      Text(
                                        gpsOffset != null
                                            ? 'x: ${gpsOffset!.dx.toStringAsFixed(2)}, y: ${gpsOffset!.dy.toStringAsFixed(2)}'
                                            : 'Not available',
                                      ),
                                    ],
                                  ));
                            },
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.customColors.customAccentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.customColors.customContainerColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: context.customColors.customShadowColor,
                                offset: const Offset(0, 2),
                                blurRadius: 10.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                showLegend = !showLegend;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Legend',
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    showLegend
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: showLegend
                                        ? context.customColors.customAccentColor
                                        : Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.color,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 80,
                      child: GestureDetector(
                        onTap: _resetZoom,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.zoom_in,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(currentScale * 100).toInt()}%',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (showLegend)
                      Positioned(
                        right: 16,
                        bottom: 80,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _legendItem(
                                  'assets/icons/legend/hostel_blocks.png',
                                  'Hostel Blocks'),
                              _legendItem('assets/icons/legend/food_places.png',
                                  'Food Places'),
                              _legendItem('assets/icons/legend/acad_blocks.png',
                                  'Academic Blocks'),
                              _legendItem('assets/icons/legend/hospital.png',
                                  'Hospital'),
                              _legendItem(
                                  'assets/icons/legend/sports.png', 'Sports'),
                              _legendItem(
                                  'assets/icons/legend/miscellaneous.png',
                                  'Miscellaneous'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
  }

  Widget _legendItem(String url, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(
            url,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
