import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemeDetailsView extends StatelessWidget {
  final Map<String, dynamic> scheme;

  const SchemeDetailsView({super.key, required this.scheme});

  Future<void> _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'notice'.tr,
        'open_link_error'.tr,
        backgroundColor: const Color(0xFFE65100),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.snackbar(
          'notice'.tr,
          'open_link_error'.tr,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'notice'.tr,
        '${'open_link_error'.tr}: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';

    final title = isHi
        ? (scheme['title_hi'] ?? scheme['title'] ?? 'योजना विवरण')
        : (scheme['title'] ?? scheme['title_hi'] ?? 'Scheme Details');
    final category = isHi
        ? (scheme['category_hi'] ?? scheme['category'] ?? 'आय सहायता')
        : (scheme['category'] ?? scheme['category_hi'] ?? 'Income Support');
    final benefit = isHi
        ? (scheme['benefit_hi'] ?? scheme['benefit'] ?? '')
        : (scheme['benefit'] ?? scheme['benefit_hi'] ?? '');
    final description = isHi
        ? (scheme['description_hi'] ?? scheme['description'] ?? '')
        : (scheme['description'] ?? scheme['description_hi'] ?? '');
    final source = isHi
        ? (scheme['department_hi'] ?? scheme['source_hi'] ?? scheme['official_source_hi'] ?? scheme['official_source'] ?? scheme['source'] ?? scheme['ministry'] ?? 'कृषि एवं किसान कल्याण मंत्रालय')
        : (scheme['official_source'] ?? scheme['source'] ?? scheme['ministry'] ?? 'Ministry of Agriculture & Farmers Welfare');
    final lastVerified = scheme['last_verified_date'] ?? scheme['last_verified'] ?? scheme['date'] ?? 'अक्टूबर 2026';
    final applyUrl = scheme['official_link'] ?? scheme['apply_url'] ?? scheme['official_url'] ?? scheme['link'] ?? 'https://pmkisan.gov.in';
    final portalUrl = scheme['official_link'] ?? scheme['official_url'] ?? scheme['apply_url'] ?? scheme['link'] ?? 'https://pmkisan.gov.in';

    final eligibilityRaw = isHi
        ? (scheme['eligibility_hi'] ?? scheme['eligibility'])
        : (scheme['eligibility'] ?? scheme['eligibility_hi']);
    final List<String> eligibility = eligibilityRaw is List
        ? eligibilityRaw.map((e) => e.toString()).toList()
        : (eligibilityRaw != null && eligibilityRaw.toString().isNotEmpty)
            ? [eligibilityRaw.toString()]
            : [
                isHi
                    ? "उन सभी भूमिधारक किसान परिवारों के लिए जिनके नाम पर खेती योग्य भूमि है।"
                    : "All landholding farmer families with cultivable land in their name."
              ];

    final docsRaw = isHi
        ? (scheme['required_documents_hi'] ?? scheme['documents_required'] ?? scheme['required_documents'])
        : (scheme['required_documents'] ?? scheme['documents_required'] ?? scheme['required_documents_hi']);
    final List<String> documents = docsRaw is List
        ? docsRaw.map((e) => e.toString()).toList()
        : (docsRaw != null && docsRaw.toString().isNotEmpty)
            ? [docsRaw.toString()]
            : [];

    final instructions = isHi
        ? (scheme['application_instructions_hi'] ?? scheme['application_instructions'] ?? scheme['application_process'] ?? '')
        : (scheme['application_instructions'] ?? scheme['application_instructions_hi'] ?? scheme['application_process'] ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left Button: Navy Blue Official Portal
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openUrl(context, portalUrl),
                    icon: const Icon(Icons.language, size: 18),
                    label: Text(
                      isHi ? 'आधिकारिक पोर्टल' : 'Official Portal',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right Button: Orange Apply Now
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openUrl(context, applyUrl),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      isHi ? 'आवेदन करें' : 'Apply Now',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card 1: Top Vivid Orange Hero Card (Screenshot 6) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE65100).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Active Pill + Category Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF76FF03),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isHi ? 'सक्रिय एवं जारी' : 'Active & Ongoing',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Scheme Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Inner Financial Benefit / Cover Box
                  if (benefit.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHi ? 'वित्तीय लाभ / कवरेज' : 'Financial Benefit / Cover',
                            style: const TextStyle(
                              color: Color(0xFFFFCC80),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.payments,
                                color: Color(0xFFFFD54F),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Footer of Hero Card: Ministry + Verified check
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          source,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Color(0xFFFFD54F), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isHi ? 'सत्यापित: $lastVerified' : 'Verified: $lastVerified',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Card 2: Overview & Objective (Screenshot 6) ──
            if (description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHi ? 'अवलोकन और उद्देश्य' : 'Overview & Objective',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Card 3: Eligibility Criteria (Screenshot 6) ──
            if (eligibility.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHi ? 'पात्रता मानदंड' : 'Eligibility Criteria',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    Column(
                      children: eligibility.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF1976D2),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Card 4: Required Documents (if available) ──
            if (documents.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF6A1B9A),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHi ? 'आवश्यक दस्तावेज' : 'Required Documents',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    Column(
                      children: documents.map((doc) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF2E7D32),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Card 5: Application Process / How to Apply ──
            if (instructions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHi ? 'आवेदन कैसे करें (चरणबद्ध प्रक्रिया)' : 'How to Apply (Step-by-Step)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    Text(
                      instructions,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
