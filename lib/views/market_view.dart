import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

class MarketView extends StatelessWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MarketController>()
        ? Get.find<MarketController>()
        : Get.put(MarketController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.filterSearch(value),
              decoration: InputDecoration(
                hintText: "Search Crop or Mandi...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                filled: true,
                fillColor: const Color(0xFFF0F7F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ── Price List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.priceList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      SizedBox(height: 16),
                      Text('Loading mandi rates...',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              if (controller.priceList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏪', style: TextStyle(fontSize: 50)),
                      const SizedBox(height: 12),
                      Text('No data available',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchPrices(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchPrices(),
                color: const Color(0xFF2E7D32),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.priceList.length,
                  itemBuilder: (context, index) {
                    final item = controller.priceList[index];
                    return _priceCard(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(dynamic item) {
    // Determine trend color & icon
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.trending_flat;
    Color trendBg = Colors.grey.withOpacity(0.1);

    if (item.trend.contains('Up') || item.trend.contains('↑')) {
      trendColor = const Color(0xFF2E7D32);
      trendIcon = Icons.trending_up;
      trendBg = const Color(0xFF2E7D32).withOpacity(0.1);
    } else if (item.trend.contains('Down') || item.trend.contains('↓')) {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
      trendBg = Colors.red.withOpacity(0.1);
    }

    // Crop emoji
    String emoji = '🌾';
    final name = item.cropName.toLowerCase();
    if (name.contains('wheat') || name.contains('गेहूं')) {
      emoji = '🌾';
    } else if (name.contains('rice') || name.contains('धान') || name.contains('chawal')) {
      emoji = '🍚';
    } else if (name.contains('cotton') || name.contains('कपास')) {
      emoji = '🏵️';
    } else if (name.contains('soya') || name.contains('सोया')) {
      emoji = '🫘';
    } else if (name.contains('onion') || name.contains('प्याज')) {
      emoji = '🧅';
    } else if (name.contains('garlic') || name.contains('लहसुन')) {
      emoji = '🧄';
    } else if (name.contains('maize') || name.contains('मक्का')) {
      emoji = '🌽';
    } else if (name.contains('mustard') || name.contains('सरसों')) {
      emoji = '🌻';
    } else if (name.contains('chana') || name.contains('चना') || name.contains('gram')) {
      emoji = '🫘';
    } else if (name.contains('masoor') || name.contains('मसूर') || name.contains('lentil')) {
      emoji = '🥘';
    } else if (name.contains('urad') || name.contains('उड़द')) {
      emoji = '🫘';
    } else if (name.contains('moong') || name.contains('मूंग')) {
      emoji = '🫛';
    } else if (name.contains('tur') || name.contains('arhar') || name.contains('तूर')) {
      emoji = '🫘';
    } else if (name.contains('tomato') || name.contains('टमाटर')) {
      emoji = '🍅';
    } else if (name.contains('potato') || name.contains('आलू')) {
      emoji = '🥔';
    } else if (name.contains('cumin') || name.contains('जीरा')) {
      emoji = '🌿';
    } else if (name.contains('coriander') || name.contains('धनिया')) {
      emoji = '🌿';
    } else if (name.contains('groundnut') || name.contains('मूंगफली')) {
      emoji = '🥜';
    } else if (name.contains('methi') || name.contains('मेथी')) {
      emoji = '🍃';
    } else if (name.contains('linseed') || name.contains('अलसी')) {
      emoji = '🌱';
    }

    // Price display
    final hasPrice = item.currentPrice != 'N/A' && item.currentPrice != 'Live';
    final hasRange = item.minPrice.isNotEmpty && item.maxPrice.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),

            // Crop name + market + range
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.cropName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.storefront_rounded,
                          size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.marketName,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (hasRange) ...[
                    const SizedBox(height: 2),
                    Text(
                      '₹${item.minPrice} – ₹${item.maxPrice}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price + trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasPrice)
                  Text(
                    '₹${item.currentPrice}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  )
                else
                  const Text(
                    '📡 Live',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  '/${item.unit}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 12, color: trendColor),
                      const SizedBox(width: 3),
                      Text(
                        item.trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}