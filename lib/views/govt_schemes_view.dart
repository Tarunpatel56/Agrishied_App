import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/govt_schemes_controller.dart';
import '../controllers/language_controller.dart';
import 'scheme_details_view.dart';

class GovtSchemesView extends StatelessWidget {
  const GovtSchemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<GovtSchemesController>()
        ? Get.find<GovtSchemesController>()
        : Get.put(GovtSchemesController());

    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'govt_schemes'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE65100),
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
            onPressed: () => c.fetchSchemes(),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'language'.tr,
            onPressed: () {
              final lang = Get.find<LanguageController>();
              lang.toggleLanguage();
              c.fetchSchemes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar (Matching Screenshot 2) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (val) => c.filterSearch(val),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: isHi ? 'योजना खोजें...' : 'Search schemes...',
                  hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFE65100)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),

          // ── Schemes List ──
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE65100)),
                );
              }

              if (c.filteredSchemes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance, size: 56, color: Color(0xFFE65100)),
                      const SizedBox(height: 12),
                      Text(
                        isHi ? 'कोई योजना नहीं मिली' : 'No schemes found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          c.filterCategory('all');
                          c.fetchSchemes();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => c.fetchSchemes(),
                color: const Color(0xFFE65100),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: c.filteredSchemes.length,
                  itemBuilder: (ctx, i) => _schemeCard(context, c.filteredSchemes[i], isHi),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _schemeCard(BuildContext context, Map<String, dynamic> scheme, bool isHi) {
    final title = isHi
        ? (scheme['title_hi'] ?? scheme['title'] ?? 'N/A')
        : (scheme['title'] ?? scheme['title_hi'] ?? 'N/A');
    final desc = isHi
        ? (scheme['description_hi'] ?? scheme['description'] ?? '')
        : (scheme['description'] ?? scheme['description_hi'] ?? '');
    final source = isHi
        ? (scheme['department_hi'] ?? scheme['source_hi'] ?? scheme['official_source_hi'] ?? scheme['official_source'] ?? scheme['source'] ?? scheme['ministry'] ?? 'कृषि एवं किसान कल्याण मंत्रालय')
        : (scheme['official_source'] ?? scheme['source'] ?? scheme['ministry'] ?? 'Ministry of Agriculture & Farmers Welfare');
    final benefit = isHi
        ? (scheme['benefit_hi'] ?? scheme['benefit'] ?? '')
        : (scheme['benefit'] ?? scheme['benefit_hi'] ?? '');
    final category = isHi
        ? (scheme['category_hi'] ?? scheme['category'] ?? 'कृषि सहायता')
        : (scheme['category'] ?? scheme['category_hi'] ?? 'Agriculture Support');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => SchemeDetailsView(scheme: scheme));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Orange Square Icon + Navy Blue Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.account_balance, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Status & Category Pills
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFC8E6C9)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E7D32),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isHi ? 'सक्रिय एवं जारी' : 'Active & Ongoing',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (category.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE7F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5E35B1),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description Snippet (2 lines max)
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 10),

                // Financial Benefit Box (matching Screenshot 2)
                if (benefit.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // Bottom Row: Ministry on Left + "View More ➔" button on Right
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, size: 14, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        source,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Get.to(() => SchemeDetailsView(scheme: scheme));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isHi ? 'अधिक जानें ➔' : 'View More ➔',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
}
