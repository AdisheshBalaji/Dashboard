import 'package:flutter/material.dart';
import 'package:dashbaord/models/merch_item_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/screens/merch_details_screen.dart';
import 'package:dashbaord/screens/merch_orders_screen.dart';

class MerchShopScreen extends StatefulWidget {
  const MerchShopScreen({Key? key}) : super(key: key);

  @override
  State<MerchShopScreen> createState() => _MerchShopScreenState();
}

class _MerchShopScreenState extends State<MerchShopScreen> {
  final ApiServices _apiServices = ApiServices();
  List<MerchItem> _merchItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMerchItems();
  }

  Future<void> _loadMerchItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _apiServices.getMerchItems();
      setState(() {
        _merchItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load merchandise items";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchandise Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MerchOrdersScreen(),
                ),
              );
            },
            tooltip: 'Order History',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMerchItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_merchItems.isEmpty) {
      return const Center(child: Text('No merchandise items available'));
    }

    return RefreshIndicator(
      onRefresh: _loadMerchItems,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _merchItems.length,
        itemBuilder: (context, index) {
          final item = _merchItems[index];
          return _buildMerchItemCard(item);
        },
      ),
    );
  }

  Widget _buildMerchItemCard(MerchItem item) {
    bool isAvailable = item.deadline.isAfter(DateTime.now());
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MerchItemDetailsScreen(itemId: item.id),
          ),
        ).then((_) => _loadMerchItems());
      },
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        isAvailable ? 'Available' : 'Closed',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
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