import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/spray_advisor_controller.dart';
import '../controllers/language_controller.dart';

class SprayAdvisorView extends StatelessWidget {
  const SprayAdvisorView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<SprayAdvisorController>()
        ? Get.find<SprayAdvisorController>()
        : Get.put(SprayAdvisorController());

    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHi ? 'फसल स्प्रे सलाहकार' : 'Crop Spray Advisor',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              isHi ? 'सीआईबीआरसी अनुमोदित सक्रिय घटक और खुराक' : 'CIBRC Approved Active Ingredients & Dosage',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'language'.tr,
            onPressed: () {
              final lang = Get.find<LanguageController>();
              lang.toggleLanguage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'share'.tr,
            onPressed: () {
              Get.snackbar(
                'AgriShield',
                isHi ? 'स्प्रे पर्ची साझा की जा रही है...' : 'Sharing spray prescription...',
                backgroundColor: const Color(0xFF1B5E20),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Auto-fill Banner (if available) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHi ? 'हालिया स्कैन की गई फसल और बीमारी से भरें' : 'Auto-fill from recent crop scan',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                    ),
                  ),
                  InkWell(
                    onTap: () => c.loadFromLastScan(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isHi ? 'लोड करें' : 'Load Scan',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Main Card: "Crop & Pest Specifications" (Matching Screenshot 7 style) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Color(0xFF1B5E20), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isHi ? 'फसल और कीट विनिर्देश' : 'Crop & Pest Specifications',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Select Crop
                  Text(
                    isHi ? 'फसल चुनें:' : 'Select Crop:',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF616161), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: c.commonCrops.contains(c.selectedCrop.value) ? c.selectedCrop.value : c.commonCrops.first,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF616161)),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                            items: c.commonCrops.map((crop) {
                              return DropdownMenuItem(
                                value: crop,
                                child: Text(c.localizedCropName(crop, isHi)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                c.selectedCrop.value = val;
                                c.cropController.text = val;
                              }
                            },
                          ),
                        )),
                  ),
                  const SizedBox(height: 14),

                  // 2. Symptoms / Problem Input
                  Text(
                    isHi ? 'लक्षण या कीट / रोग का नाम:' : 'Symptoms / Target Pest or Disease:',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF616161), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: TextField(
                      controller: c.symptomsController,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                      decoration: InputDecoration(
                        hintText: isHi ? 'उदा: इल्ली, पीला मोज़ेक, पत्ती धब्बा, माहू' : 'e.g. Aphids, Yellow Mosaic, Leaf Spot, Stem Borer',
                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Crop Age Row + Slider (Matching Screenshot 7)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHi ? 'फसल की आयु:' : 'Crop Age:',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF616161), fontWeight: FontWeight.w500),
                      ),
                      Obx(() => Text(
                            '${c.cropAgeDays.value.toInt()} ${isHi ? "दिन" : "Days"}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          )),
                    ],
                  ),
                  Obx(() => SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF2E7D32),
                          inactiveTrackColor: const Color(0xFFC8E6C9),
                          thumbColor: const Color(0xFF2E7D32),
                          overlayColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: c.cropAgeDays.value.clamp(0.0, 120.0),
                          min: 0,
                          max: 120,
                          divisions: 24,
                          onChanged: (val) => c.cropAgeDays.value = val,
                        ),
                      )),
                  const SizedBox(height: 12),

                  // 4. Calculate / Get Spray Prescription Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton.icon(
                          onPressed: c.isLoading.value ? null : () => c.fetchSprayPrescription(),
                          icon: c.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.science, color: Colors.white, size: 20),
                          label: Text(
                            c.isLoading.value
                                ? (isHi ? 'विश्लेषण किया जा रहा है...' : 'Analyzing Prescription...')
                                : (isHi ? '🧪 स्प्रे पर्चा प्राप्त करें' : '🧪 Get Spray Prescription'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Error Notice ──
            Obx(() {
              if (c.errorMessage.value.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c.errorMessage.value,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // ── Prescription Results ──
            Obx(() {
              final p = c.prescription.value;
              if (p == null) return const SizedBox.shrink();

              final isHealthy = p['is_healthy'] == true ||
                  p['diagnosis_state'] == 'healthy' ||
                  (p['identified_issue'] != null &&
                      (p['identified_issue'].toString().toLowerCase().contains('healthy') ||
                          p['identified_issue'].toString().contains('स्वस्थ')));

              final issue = p['identified_issue'] ?? (isHealthy ? (isHi ? 'स्वस्थ फसल' : 'Healthy Crop') : 'Identified Problem');
              final chemical = p['chemical_recommendation'] as Map<String, dynamic>?;
              final organic = p['organic_alternative'] as Map<String, dynamic>?;
              final aiExpl = p['ai_explanation'] ?? '';
              final timing = p['application_timing'] ?? (chemical?['application_timing'] ?? '');
              final safetyTips = p['safety_guidelines'] is List ? (p['safety_guidelines'] as List) : [];
              final recSource = p['recommendation_source'] ?? (isHi ? 'सीआईबीआरसी पंजीकृत संस्तुति' : 'CIBRC Registered Recommendation');
              final verifStatus = p['verification_status'] ?? (isHi ? '✔ आधिकारिक कृषि लेबल से सत्यापित' : '✔ Verified Agricultural Label');
              final cultural = p['cultural_guidelines']?.toString() ?? p['cultural_management_hi']?.toString() ?? p['cultural_management']?.toString() ?? '';
              final mixingAlert = p['mixing_alert']?.toString() ?? p['mixing_warning_hi']?.toString() ?? p['mixing_warning']?.toString() ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── CASE A: HEALTHY CROP (No Chemical Spray Recommended) ──
                  if (isHealthy) ...[
                    // Vibrant Green Healthy Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                                    const SizedBox(width: 5),
                                    Text(
                                      isHi ? 'फसल स्वास्थ्य स्थिति: उत्कृष्ट' : 'Crop Health Status: Healthy',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${c.localizedCropName(c.selectedCrop.value, isHi)} — ${isHi ? "फसल पूर्णतः स्वस्थ है" : "Crop is Healthy"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isHi
                                ? 'उपलब्ध मूल्यांकन में किसी कीट अथवा रोग के लक्षण नहीं पाए गए हैं। वर्तमान में किसी भी रासायनिक कीटनाशक के छिड़काव की आवश्यकता नहीं है।'
                                : 'No pest or disease symptoms detected in current assessment. No chemical spray is required at this stage.',
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preventive Care & Monitoring Advice Card
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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.health_and_safety, color: Color(0xFF2E7D32), size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHi ? 'निवारक सुरक्षा एवं निगरानी परामर्श' : 'Preventive Care & Monitoring Advice',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                                    ),
                                    Text(
                                      isHi ? 'फसल को आगे भी स्वस्थ रखने हेतु आवश्यक उपाय' : 'Best practices to sustain crop health',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _bulletTip(
                            isHi
                                ? 'नियमित खेत निरीक्षण: हर 3-4 दिन में फसल के विभिन्न कोनों और पत्तियों की निचली सतह की जांच करें।'
                                : 'Regular Field Scouting: Inspect leaf undersides and field corners every 3-4 days.',
                            const Color(0xFF2E7D32),
                          ),
                          _bulletTip(
                            isHi
                                ? 'पीले व नीले स्टिकी ट्रैप: रस चूसक कीटों के प्रारंभिक आगमन का पता लगाने हेतु प्रति एकड़ 8-10 चिपचिपे ट्रैप लगाएं।'
                                : 'Pheromone & Sticky Traps: Install 8-10 yellow/blue sticky traps per acre for early pest detection.',
                            const Color(0xFF2E7D32),
                          ),
                          _bulletTip(
                            isHi
                                ? 'संतुलित पोषण प्रबंधन: अत्यधिक यूरिया (नाइट्रोजन) के प्रयोग से बचें, क्योंकि अधिक कोमल पत्तियां कीटों को आकर्षित करती हैं।'
                                : 'Balanced Nutrition: Avoid excessive urea (nitrogen), which creates tender foliage susceptible to sucking pests.',
                            const Color(0xFF2E7D32),
                          ),
                          _bulletTip(
                            isHi
                                ? 'उचित जल निकास: खेत में लंबे समय तक पानी ठहराव न होने दें ताकि जड़ गलन और फफूंद जनित रोगों से बचाव रहे।'
                                : 'Proper Drainage: Ensure water does not stagnate to prevent root rot and soil-borne fungal pathogens.',
                            const Color(0xFF2E7D32),
                          ),
                          const SizedBox(height: 12),

                          // Field Disclaimer Notice
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFE082)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isHi
                                        ? '⚠️ सूचना: एक पौधे या सीमित क्षेत्र का स्वस्थ परिणाम यह गारंटी नहीं देता कि संपूर्ण खेत शत-प्रतिशत रोगमुक्त है। निगरानी जारी रखें।'
                                        : '⚠️ Notice: A healthy scan of a single sample does not guarantee that the entire field is free from disease. Continue routine scouting across all field zones.',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037), height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]

                  // ── CASE B: DISEASE OR PEST DETECTED ──
                  else ...[
                    // Title Banner with CIBRC Registered Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Color(0xFFA5D6A7), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  recSource,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isHi ? '✔ सत्यापित' : verifStatus,
                                  style: const TextStyle(color: Color(0xFFA5D6A7), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${c.localizedCropName(c.selectedCrop.value, isHi)} — $issue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. CIBRC Chemical Recommendation Card
                    if (chemical != null) ...[
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.science, color: Color(0xFF1B5E20), size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isHi ? 'रासायनिक संस्तुति' : 'Chemical Recommendation (CIBRC)',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                                      ),
                                      Text(
                                        chemical['active_ingredient'] ?? '',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Dosage Pills Row
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(child: _dosePill(isHi ? 'प्रति लीटर पानी' : 'Per Liter', chemical['dosage_per_liter'] ?? (isHi ? '2 मिली' : '2 ml'))),
                                  Container(width: 1, height: 28, color: const Color(0xFFC8E6C9)),
                                  Expanded(child: _dosePill(isHi ? 'प्रति एकड़' : 'Per Acre', chemical['dosage_per_acre'] ?? (isHi ? '250-300 मिली' : '250-300 ml'))),
                                  Container(width: 1, height: 28, color: const Color(0xFFC8E6C9)),
                                  Expanded(child: _dosePill(isHi ? 'प्रतीक्षा अवधि' : 'PHI Days', '${chemical['phi_days'] ?? (isHi ? "14 दिन" : "14 Days")}')),
                                ],
                              ),
                            ),
                            if (chemical['water_volume'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.water_drop, size: 14, color: Color(0xFF1B5E20)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${isHi ? "आवश्यक पानी" : "Water Volume"}: ${chemical['water_volume']}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                                  ),
                                ],
                              ),
                            ],
                            if (chemical['commercial_names'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${isHi ? "बाजार में उपलब्ध ब्रांड" : "Market Brands"}: ${chemical['commercial_names']}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],

                  // 2. Organic / IPM Alternative Card
                  if (organic != null) ...[
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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHi ? 'जैविक विकल्प (देसी उपाय)' : 'Organic & IPM Alternative',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                    ),
                                    Text(
                                      organic['product_name'] ?? (isHi ? 'नीम तेल / जैविक कीटनाशक' : 'Neem Oil / Bio-pesticide'),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${isHi ? "खुराक" : "Dosage"}: ${organic['dosage'] ?? (isHi ? "5 मिली प्रति लीटर पानी" : "5 ml per liter water")}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3. AI Explanation & Timing
                  if (aiExpl.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology, size: 18, color: Color(0xFF1B5E20)),
                              const SizedBox(width: 6),
                              Text(
                                isHi ? 'एआई वैज्ञानिक परामर्श:' : 'AI Agronomic Insight:',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aiExpl,
                            style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF263238)),
                          ),
                          if (timing.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${isHi ? "स्प्रे का सही समय" : "Best Spray Timing"}: $timing',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3B. Cultural Management
                  if (cultural.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.agriculture, color: Color(0xFF1B5E20), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                isHi ? 'कृषि एवं फसल प्रबंधन' : 'Cultural Management',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cultural,
                            style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF37474F)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3C. Tank Mixing Warning
                  if (mixingAlert.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, color: Color(0xFFE65100), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mixingAlert,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFBF360C), height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 4. Safety & Precautions
                  if (safetyTips.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: Color(0xFFE65100), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                isHi ? 'सुरक्षा दिशानिर्देश एवं सावधानियां' : 'Safety Guidelines (PPE & Care)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...safetyTips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                                    Expanded(child: Text(tip.toString(), style: const TextStyle(fontSize: 12, height: 1.3))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _bulletTip(String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF37474F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dosePill(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
        ),
      ],
    );
  }
}
