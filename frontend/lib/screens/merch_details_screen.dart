import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashbaord/models/merch_item_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/screens/merch_payment_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MerchItemDetailsScreen extends StatefulWidget {
  final int itemId;

  const MerchItemDetailsScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<MerchItemDetailsScreen> createState() => _MerchItemDetailsScreenState();
}

class _MerchItemDetailsScreenState extends State<MerchItemDetailsScreen> {
  final ApiServices _apiServices = ApiServices();
  MerchItem? _item;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedSize = 'M';
  final List<String> _availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final item = await _apiServices.getMerchItem(widget.itemId);
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load merchandise details";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item?.title ?? 'Item Details'),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _item != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBottomBar() {
    bool isAvailable = _item!.deadline.isAfter(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '₹${_item!.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isAvailable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MerchPaymentScreen(
                              item: _item!,
                              selectedSize: _selectedSize,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isAvailable ? 'Buy Now' : 'Deadline Passed',
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadItemDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_item == null) {
      return const Center(child: Text('Item not found'));
    }

    bool isAvailable = _item!.deadline.isAfter(DateTime.now());
    final dateFormat = DateFormat('MMM d, y');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Hero(
            tag: 'merch_image_${_item!.id}',
            child: CachedNetworkImage(
              imageUrl: _item!.imageUrl,
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.error, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable ? Colors.green.shade300 : Colors.red.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable ? Icons.schedule : Icons.cancel_outlined,
                          size: 18,
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isAvailable
                                ? 'Order by: ${dateFormat.format(_item!.deadline)}'
                                : 'Deadline passed: ${dateFormat.format(_item!.deadline)}',
                            style: TextStyle(
                              color: isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _item!.description,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableSizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 60,
                        height: 60,
                        child: Material(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          elevation: isSelected ? 2 : 0,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected 
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}