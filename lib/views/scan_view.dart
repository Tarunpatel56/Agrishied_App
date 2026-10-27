import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_controller.dart';
import 'spray_advisor_view.dart';
import 'fertilizer_advisor_view.dart';


class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F0),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState();
        if (controller.result.value == null) return _buildPlaceholder(controller);

        final data = controller.result.value!;
        return _buildResultView(data, controller);
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showImagePicker,
        label: Text(
          (Get.locale?.languageCode ?? 'hi') == 'hi' ? "फसल स्कैन" : "Crop Scan",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

  }

  // ==========================================
  // LOADING STATE
  // ==========================================
  Widget _buildLoadingState() {
    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isHi ? "आपकी फसल की जांच जारी है..." : "Analyzing Your Crop...",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text(
            isHi ? "एआई मॉडल फसल की स्वास्थ्य स्थिति की जांच कर रहा है" : "AI is examining the image",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ==========================================
  // PLACEHOLDER (No scan yet)
  // ==========================================
  Widget _buildPlaceholder(ScanController controller) {
    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.eco, size: 70, color: Color(0xFF2E7D32)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isHi ? "अपनी फसल स्कैन करें" : "Scan Your Crop",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isHi
                  ? "तत्काल रोग निदान और उपचार योजना के लिए फोटो खींचें या फसल की छवि अपलोड करें"
                  : "Take a photo or upload crop image for instant\ndisease diagnosis & recovery plan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // RESULT VIEW
  // ==========================================
  Widget _buildResultView(data, ScanController controller) {
    final isHi = (Get.locale?.languageCode ?? 'hi') == 'hi';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // 0. SCAN HISTORY CHIPS (multiple scans)
        if (controller.scanHistory.length > 1) ...[
          _buildScanHistoryChips(controller, isHi),
          const SizedBox(height: 12),
        ],

        // 1. CROP HEADER
        _buildCropHeader(data, isHi),
        const SizedBox(height: 16),

        // 2. HEALTH SCORE BAR
        _buildHealthBar(data.healthScore, data.healthStatus, isHi),
        const SizedBox(height: 16),

        // 3. INFO GRID (Age, Stage, Harvest)
        _buildInfoGrid(data, isHi),
        const SizedBox(height: 16),

        // 4. HARVEST PREDICTION
        _buildSection(
          isHi ? "🌾 कटाई अनुमान" : "🌾 Harvest Prediction",
          const Color(0xFF1B5E20),
          [
            _buildDetailRow(Icons.calendar_today, isHi ? "अनुमानित तारीख" : "Expected Date", data.harvestDate),
            _buildDetailRow(Icons.timer, isHi ? "शेष दिन" : "Days Remaining", "${data.harvestDays} ${isHi ? 'दिन' : 'days'}"),
            _buildDetailRow(Icons.loop, isHi ? "कुल फसल चक्र" : "Total Lifecycle", "${data.totalLifecycle} ${isHi ? 'दिन' : 'days'}"),
            _buildDetailRow(Icons.check_circle_outline, isHi ? "कटाई तत्परता" : "Harvest Readiness", data.harvestReadiness),
          ],
        ),
        const SizedBox(height: 12),

        // 5. FIELD ANALYSIS (Pros & Cons)
        _buildSection(
          isHi ? "📊 खेत विश्लेषण" : "📊 Field Analysis",
          Colors.teal,
          [
            _buildHighlightBox(isHi ? "मजबूत पक्ष (सकारात्मक)" : "Strengths", data.localizedPros(isHi), Colors.green),
            const SizedBox(height: 10),
            _buildHighlightBox(isHi ? "कमियां एवं समस्याएं" : "Issues", data.localizedCons(isHi), Colors.orange),
          ],
        ),
        const SizedBox(height: 12),

        // 6. GROWTH ADVISORY
        _buildSection(
          isHi ? "🌱 बढ़वार एवं पोषण सलाह" : "🌱 Growth Advisory",
          Colors.blue[800]!,
          [
            _buildDetailRow(Icons.science, isHi ? "पोषक तत्व आवश्यकता" : "Nutrient Needs", data.requirements),
            const Divider(height: 20),
            _buildDetailRow(Icons.shopping_bag, isHi ? "संस्तुत उत्पाद" : "Products", data.products),
            const Divider(height: 20),
            _buildDetailRow(Icons.water_drop, isHi ? "सिंचाई सलाह" : "Irrigation", data.irrigationAdvice),
            const Divider(height: 20),
            _buildDetailRow(Icons.compost, isHi ? "उर्वरक सलाह" : "Fertilizer", data.fertilizerRecommendation),
          ],
        ),
        const SizedBox(height: 12),

        // 7. GROWTH TIPS
        _buildSection(
          isHi ? "💡 फसल वृद्धि के नुस्खे" : "💡 Growth Tips",
          Colors.purple,
          [
            Text(
              data.growthTips,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF333333)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 8. DISEASE ALERT
        _buildDiseaseSection(data, isHi),
        const SizedBox(height: 16),

        // 8B. PEST DETECTION
        _buildPestSection(data, isHi),
        const SizedBox(height: 16),

        // 9. AI ADVISOR ACTIONS (Crop Scan Integration)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC8E6C9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                  const Icon(Icons.auto_awesome, color: Color(0xFF1B5E20), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    (Get.locale?.languageCode ?? 'hi') == 'hi'
                        ? 'एआई वैज्ञानिक परामर्श'
                        : 'AI Agronomic Advisors',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final ageVal = double.tryParse(data.age.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 25.0;
                        Get.to(() => const SprayAdvisorView(), arguments: {
                          'crop_name': data.cropName,
                          'disease': (data.disease.isNotEmpty && data.disease != 'N/A') ? data.disease : data.healthStatus,
                          'crop_age': ageVal,
                          'auto_fetch': true,
                        });
                      },
                      icon: const Icon(Icons.science, size: 16, color: Colors.white),
                      label: Text(
                        (Get.locale?.languageCode ?? 'hi') == 'hi' ? 'स्प्रे पर्चा' : 'Spray Advisor',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final ageVal = double.tryParse(data.age.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 25.0;
                        Get.to(() => const FertilizerAdvisorView(), arguments: {
                          'crop_name': data.cropName,
                          'crop_age': ageVal,
                          'auto_calc': true,
                        });
                      },
                      icon: const Icon(Icons.inventory_2, size: 16, color: Colors.white),
                      label: Text(
                        (Get.locale?.languageCode ?? 'hi') == 'hi' ? 'उर्वरक गणना' : 'Fertilizer Plan',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 10. INSURANCE ELIGIBILITY & CLAIMS
        Obx(() => _buildEligibilityCard(controller, isHi)),
        const SizedBox(height: 14),
        Obx(() => _buildClaimButtons(controller, isHi)),
        const SizedBox(height: 14),
        _buildInsuranceReport(data, controller, isHi),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==========================================
  // SCAN HISTORY CHIPS
  // ==========================================
  Widget _buildScanHistoryChips(ScanController controller, [bool isHi = false]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHi ? '📋 स्कैन इतिहास (${controller.scanHistory.length} स्कैन)' : '📋 Scan History (${controller.scanHistory.length} scans)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.scanHistory.length,
              itemBuilder: (ctx, i) {
                final scan = controller.scanHistory[i];
                final isSelected = controller.currentScanIndex.value == i;
                final cropDisplayName = isHi && scan.cropNameHindi.isNotEmpty ? scan.cropNameHindi : scan.cropName;
                return GestureDetector(
                  onTap: () => controller.viewScan(i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '$cropDisplayName (${scan.healthScore}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INSURANCE ELIGIBILITY CARD
  // ==========================================
  Widget _buildEligibilityCard(ScanController controller, [bool isHi = false]) {
    final eligible = controller.insuranceEligible.value;
    final reason = controller.eligibilityReason.value;
    final data = controller.eligibilityData.value;

    if (reason.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: eligible ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: eligible ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                eligible ? Icons.verified : Icons.cancel,
                color: eligible ? Colors.green[700] : Colors.red[700],
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  eligible
                      ? (isHi ? '✅ फसल बीमा क्लेम हेतु पात्र' : '✅ Insurance Eligible')
                      : (isHi ? '❌ फसल बीमा हेतु अपात्र' : '❌ Insurance Not Eligible'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: eligible ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reason,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: eligible ? Colors.green[900] : Colors.red[900],
            ),
          ),
          if (data != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _eligibilityChip(
                  isHi ? '⚠️ नुकसान' : '⚠️ Damage',
                  '${data['damage_percent']}%',
                  (data['damage_percent'] ?? 0) >= 40 ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 8),
                _eligibilityChip(
                  isHi ? '🦠 रोग' : '🦠 Disease',
                  data['has_disease'] == true ? (isHi ? 'पाया गया' : 'Detected') : (isHi ? 'नहीं' : 'None'),
                  data['has_disease'] == true ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                _eligibilityChip(
                  isHi ? '🌤️ मौसम' : '🌤️ Weather',
                  data['weather_supports'] == true ? (isHi ? 'पुष्टि' : 'Corroborated') : (isHi ? 'सामान्य' : 'Normal'),
                  data['weather_supports'] == true ? Colors.orange : Colors.blue,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _eligibilityChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CLAIM FILING BUTTONS
  // ==========================================
  Widget _buildClaimButtons(ScanController controller, [bool isHi = false]) {
    final eligible = controller.insuranceEligible.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: Color(0xFF1B5E20), size: 20),
              const SizedBox(width: 8),
              Text(
                isHi ? '🛡️ फसल बीमा क्लेम दर्ज करें' : '🛡️ File Insurance Claim',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            eligible
                ? (isHi ? 'अकाट्य साक्ष्य हेतु ब्लॉकचेन (IPFS) पर सुरक्षित अपलोड' : 'Upload to blockchain (IPFS) for tamper-proof evidence')
                : (isHi ? 'बीमा क्लेम दर्ज करने के लिए फसल में नुकसान होना अनिवार्य है' : 'Crop must have damage for insurance claim filing'),
            style: TextStyle(fontSize: 12, color: eligible ? Colors.grey[600] : Colors.red[400]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Government Relief
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: eligible ? () => controller.fileGovtClaim() : null,
                    icon: const Icon(Icons.account_balance, size: 18),
                    label: Text(
                      isHi ? 'सरकारी राहत' : 'Sarkari Rahat',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: eligible ? 2 : 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Private Insurance
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: eligible ? () => controller.filePrivateClaim() : null,
                    icon: const Icon(Icons.business, size: 18),
                    label: Text(
                      isHi ? 'निजी क्लेम' : 'Private Claim',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: eligible ? 2 : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FULL INSURANCE REPORT SECTION
  // ==========================================
  Widget _buildInsuranceReport(data, ScanController controller, [bool isHi = false]) {
    final eligData = controller.eligibilityData.value;
    final int damagePercent = (100 - data.healthScore as int).clamp(0, 100);
    final bool hasDisease = data.disease.toLowerCase() != 'no disease detected' &&
        data.disease.toLowerCase() != 'healthy' &&
        data.disease.toLowerCase() != 'n/a';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.indigo[700], size: 20),
              const SizedBox(width: 8),
              Text(
                isHi ? '📄 फसल बीमा विश्लेषण रिपोर्ट' : '📄 Insurance Analysis Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Report Table
          _reportRow(
            isHi ? 'फसल का नाम' : 'Crop Name',
            isHi && data.cropNameHindi.isNotEmpty ? data.cropNameHindi : data.cropName,
            Icons.eco,
          ),
          _reportRow(
            isHi ? 'स्वास्थ्य स्कोर' : 'Health Score',
            '${data.healthScore}%',
            Icons.favorite,
            color: data.healthScore >= 60 ? Colors.green : Colors.red,
          ),
          _reportRow(
            isHi ? 'नुकसान स्तर' : 'Damage Level',
            '$damagePercent%',
            Icons.warning_amber,
            color: damagePercent > 70 ? Colors.red : damagePercent > 40 ? Colors.orange : Colors.green,
          ),
          _reportRow(
            isHi ? 'फसल रोग' : 'Disease',
            isHi ? (hasDisease ? data.disease : 'कोई रोग नहीं मिला') : data.disease,
            Icons.coronavirus,
            color: hasDisease ? Colors.red : Colors.green,
          ),
          if (hasDisease) ...[
            _reportRow(isHi ? 'रोग का कारण' : 'Disease Cause', data.diseaseCause, Icons.help_outline),
            _reportRow(isHi ? 'उपचार' : 'Treatment', data.treatment, Icons.medical_services),
          ],
          _reportRow(
            isHi ? 'स्वास्थ्य स्थिति' : 'Health Status',
            isHi ? (data.healthScore >= 80 ? 'पूर्णतः स्वस्थ' : data.healthScore >= 60 ? 'मध्यम तनाव' : 'गंभीर रोगग्रस्त') : data.healthStatus,
            Icons.monitor_heart,
          ),
          _reportRow(
            isHi ? 'कीट' : 'Pest',
            isHi ? (data.pestDetected.toLowerCase().contains('no') || data.pestDetected == 'N/A' ? 'कोई कीट नहीं मिला' : data.pestDetected) : data.pestDetected,
            Icons.pest_control,
            color: data.pestDetected.toLowerCase() != 'no pest detected' &&
                data.pestDetected.toLowerCase() != 'n/a'
                ? Colors.orange : Colors.green,
          ),

          const Divider(height: 20),

          // Weather Corroboration
          Row(
            children: [
              Icon(Icons.cloud, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  eligData?['weather_supports'] == true
                      ? (isHi ? 'मौसम: ✅ मौसम नुकसान के जोखिम की पुष्टि करता है' : 'Weather: ✅ Weather confirms damage risk')
                      : (isHi ? 'मौसम: ☀️ सामान्य मौसमी परिस्थितियां' : 'Weather: ☀️ Normal weather conditions'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: eligData?['weather_supports'] == true ? Colors.orange[800] : Colors.blue[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Eligibility Verdict
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.insuranceEligible.value ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: controller.insuranceEligible.value ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  controller.insuranceEligible.value ? Icons.check_circle : Icons.cancel,
                  color: controller.insuranceEligible.value ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.insuranceEligible.value
                        ? (isHi ? 'अंतिम निर्णय: बीमा क्लेम हेतु पात्र ✅' : 'VERDICT: Eligible for Insurance ✅')
                        : (isHi ? 'अंतिम निर्णय: बीमा क्लेम हेतु अपात्र ❌' : 'VERDICT: Not Eligible for Insurance ❌'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: controller.insuranceEligible.value ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildCropHeader(data, [bool isHi = false]) {
    final primaryName = isHi && data.cropNameHindi.isNotEmpty ? data.cropNameHindi : data.cropName;
    final secondaryName = isHi ? '' : (data.cropNameHindi.isNotEmpty ? data.cropNameHindi : '');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (secondaryName.isNotEmpty)
                  Text(
                    secondaryName,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isHi ? "एआई सटीकता: ${data.confidence}%" : "AI Confidence: ${data.confidence}%",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBar(int score, String status, [bool isHi = false]) {
    Color barColor;
    if (score >= 80) {
      barColor = Colors.green;
    } else if (score >= 60) {
      barColor = Colors.orange;
    } else if (score >= 40) {
      barColor = Colors.deepOrange;
    } else {
      barColor = Colors.red;
    }

    String statusText = status;
    if (isHi) {
      final s = status.toLowerCase();
      if (s.contains('healthy') || s.contains('स्वस्थ')) {
        statusText = 'पूर्णतः स्वस्थ';
      } else if (s.contains('moderate') || s.contains('मध्यम')) {
        statusText = 'मध्यम तनाव';
      } else if (s.contains('severe') || s.contains('गंभीर')) {
        statusText = 'गंभीर तनाव';
      } else if (s.contains('critical') || s.contains('खतरनाक') || s.contains('संकट')) {
        statusText = 'अति संकटग्रस्त';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isHi ? "फसल स्वास्थ्य स्कोर" : "Crop Health Score", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusText, style: TextStyle(color: barColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[200],
                    color: barColor,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text("$score%", style: TextStyle(color: barColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(data, [bool isHi = false]) {
    return Row(
      children: [
        _infoTile(isHi ? "फसल आयु" : "Crop Age", data.age, Icons.calendar_today, Colors.blue),
        const SizedBox(width: 8),
        _infoTile(isHi ? "विकास अवस्था" : "Growth Stage", data.stage, Icons.grass, Colors.green),
        const SizedBox(width: 8),
        _infoTile(isHi ? "कटाई समय" : "Harvest In", "${data.harvestDays}${isHi ? ' दिन' : 'd'}", Icons.timer, Colors.orange),
      ],
    );
  }

  Widget _infoTile(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color titleColor, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String label, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                label == "Strengths" ? Icons.check_circle : Icons.warning_amber,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.5)),
        ],
      ),
    );
  }

  // ==========================================
  // PEST DETECTION SECTION
  // ==========================================
  Widget _buildPestSection(data, [bool isHi = false]) {
    final bool hasPest = data.pestDetected.toLowerCase() != 'no pest detected' &&
        data.pestDetected.toLowerCase() != 'none' &&
        data.pestDetected.toLowerCase() != 'n/a';

    final String titleText = hasPest
        ? (isHi ? "🐛 कीट का प्रकोप देखा गया" : "🐛 Pest Detected")
        : (isHi ? "✅ कोई हानिकारक कीट नहीं" : "✅ No Pest Detected");

    final String pestLabel = isHi ? "कीट" : "Pest";
    final String typeLabel = isHi ? "कीट प्रकार" : "Type";
    final String organicTitle = isHi ? "🌿 जैविक रोकथाम (देसी उपाय)" : "🌿 Organic Removal";
    final String chemicalTitle = isHi ? "🧪 रासायनिक उपचार" : "🧪 Chemical Treatment";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasPest ? Border.all(color: Colors.orange.withOpacity(0.4), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasPest ? Icons.pest_control : Icons.verified,
                color: hasPest ? Colors.orange[700] : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                titleText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: hasPest ? Colors.orange[800] : Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.bug_report, pestLabel, data.localizedPest(isHi)),
          if (hasPest) ...[
            _buildDetailRow(Icons.category, typeLabel, data.pestType),
            const Divider(height: 16),
            // Organic removal — green card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organicTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.pestRemovalOrganic,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF333333)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Chemical removal — orange card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chemicalTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.pestRemovalChemical,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF333333)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // DISEASE SECTION
  // ==========================================
  Widget _buildDiseaseSection(data, [bool isHi = false]) {
    final bool hasDisease = data.disease.toLowerCase() != 'no disease detected' &&
        data.disease.toLowerCase() != 'healthy' &&
        data.disease.toLowerCase() != 'n/a';

    final String titleText = hasDisease
        ? (isHi ? "⚠️ फसल रोग का प्रकोप देखा गया" : "⚠️ Disease Detected")
        : (isHi ? "✅ कोई रोग नहीं मिला" : "✅ No Disease Detected");

    final String diseaseLabel = isHi ? "फसल रोग" : "Disease";
    final String causeLabel = isHi ? "रोग का कारण" : "Cause";
    final String preventionLabel = isHi ? "रोकथाम व बचाव" : "Prevention";
    final String treatmentLabel = isHi ? "💊 उपचार परामर्श" : "💊 Treatment";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasDisease ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasDisease ? Icons.bug_report : Icons.verified,
                color: hasDisease ? Colors.red : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                titleText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: hasDisease ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.coronavirus, diseaseLabel, data.localizedDisease(isHi)),
          if (hasDisease) ...[
            _buildDetailRow(Icons.help_outline, causeLabel, data.diseaseCause),
            _buildDetailRow(Icons.shield, preventionLabel, data.diseasePrevention),
            const Divider(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatmentLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.localizedTreatment(isHi),
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => const SprayAdvisorView(), arguments: {
                          'crop_name': data.cropName,
                          'disease': data.disease,
                        });
                      },
                      icon: const Icon(Icons.science_rounded, size: 16),
                      label: Text(
                        isHi
                            ? 'विशेषज्ञ स्प्रे सलाह पर्ची देखें'
                            : 'Get CIBRC Spray Prescription',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}