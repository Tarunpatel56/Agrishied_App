import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';
import '../models/market_model.dart';

class MarketView extends StatelessWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<MarketController>()
        ? Get.find<MarketController>()
        : Get.put(MarketController());

    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'market_rates'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'retry'.tr,
            onPressed: () => c.fetchPrices(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar (Matching Screenshot 5) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (value) => c.filterSearch(value),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: isHi ? 'फसल या मंडी खोजें...' : 'Search Crop or Market...',
                  hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),

          // ── Mandi Cards List ──
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.priceList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                );
              }

              if (c.priceList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏪', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        isHi ? 'कोई मंडी भाव उपलब्ध नहीं है' : 'No mandi prices found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          c.selectedState.value = 'all';
                          c.fetchPrices();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr),
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
                onRefresh: () => c.fetchPrices(),
                color: const Color(0xFF2E7D32),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: c.priceList.length,
                  itemBuilder: (context, index) {
                    final item = c.priceList[index];
                    return _mandiCard(context, c, item, isHi);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _mandiCard(BuildContext context, MarketController c, MarketModel item, bool isHi) {
    // Trend Pill determination
    Color trendBg = const Color(0xFFF5F5F5);
    Color trendColor = const Color(0xFF757575);
    String trendText = isHi ? '→ स्थिर' : '→ Stable →';

    final t = item.trend.toLowerCase();
    if (t.contains('up') || t.contains('↑') || t.contains('+') || item.trendPct.contains('+')) {
      trendBg = const Color(0xFFE8F5E9);
      trendColor = const Color(0xFF2E7D32);
      trendText = isHi ? '↗ बढ़ रहा है' : '↗ Up ↑';
    } else if (t.contains('down') || t.contains('↓') || t.contains('-') || item.trendPct.contains('-')) {
      trendBg = const Color(0xFFFFEBEE);
      trendColor = const Color(0xFFC62828);
      trendText = isHi ? '↘ घट रहा है' : '↘ Down ↓';
    }

    String emoji = _getEmojiForCrop(item.cropName);
    final displayName = item.localizedCropName(isHi);

    // Range display
    final minP = item.minPrice.isNotEmpty ? item.minPrice : ((int.tryParse(item.currentPrice) ?? 2500) - 100).toString();
    final maxP = item.maxPrice.isNotEmpty ? item.maxPrice : ((int.tryParse(item.currentPrice) ?? 2500) + 100).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAiTrendSheet(context, c, item, isHi),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Emoji Icon | Crop Info | Price & Trend
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mint square with Crop Emoji
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Middle: Crop Name, Mandi, Range
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.storefront, size: 14, color: Color(0xFF757575)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.marketName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF616161),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Range: ₹$minP – ₹$maxP',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right: Price, Unit, Trend Pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${item.currentPrice}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        Text(
                          item.unit.isNotEmpty ? '/${item.unit.replaceAll('per ', '').replaceAll('/', '')}' : '/Quintal',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: trendBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trendText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: trendColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Row: "✔ Live Mandi Rate" pill on Left + Agmarknet source on Right
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 12, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 4),
                          Text(
                            isHi ? 'लाइव मंडी भाव' : 'Live Mandi Rate',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Government of India — Agmarknet (${item.lastUpdated})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAiTrendSheet(BuildContext context, MarketController c, MarketModel item, bool isHi) {
    c.fetchAiTrend(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF2E7D32), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.localizedCropName(isHi),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.marketName,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Trend Content
              Obx(() {
                if (c.isAiTrendLoading.value) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                        const SizedBox(height: 12),
                        Text(
                          isHi ? 'जेमिनी और ग्रॉक द्वारा मंडी रुझान विश्लेषण...' : 'Gemini & Grok analyzing market trends...',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_outlined, size: 16, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 6),
                          Text(
                            isHi ? 'एआई बाजार विश्लेषण एवं सलाह:' : 'AI Market Insight & Advice:',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.aiTrendInsight.value,
                        style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF263238)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFF57F17)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isHi
                            ? 'सूचना: यह एआई विश्लेषण ऐतिहासिक रुझानों और आवक पर आधारित है। वास्तविक बिक्री भाव स्थानीय मंडी में फसल की गुणवत्ता पर निर्भर करता है।'
                            : 'Notice: This AI analysis is based on historical patterns and arrivals. Real price depends on crop quality at local APMC.',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFF57F17), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getEmojiForCrop(String name) {
    final n = name.toLowerCase();
    if (n.contains('wheat') || n.contains('गेहूं')) return '🌾';
    if (n.contains('rice') || n.contains('धान') || n.contains('चावल') || n.contains('paddy')) return '🌾';
    if (n.contains('cotton') || n.contains('कपास')) return '🏵️';
    if (n.contains('soya') || n.contains('सोयाबीन')) return '🫘';
    if (n.contains('onion') || n.contains('प्याज़')) return '🧅';
    if (n.contains('garlic') || n.contains('लहसुन')) return '🧄';
    if (n.contains('maize') || n.contains('मक्का')) return '🌽';
    if (n.contains('mustard') || n.contains('सरसों')) return '🌻';
    if (n.contains('chana') || n.contains('चना') || n.contains('gram') || n.contains('beans')) return '🫘';
    if (n.contains('tomato') || n.contains('टमाटर')) return '🍅';
    if (n.contains('potato') || n.contains('आलू')) return '🥔';
    if (n.contains('brinjal') || n.contains('बैंगन')) return '🍆';
    return '🌾';
  }
}