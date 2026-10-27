import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/fertilizer_advisor_controller.dart';
import '../controllers/language_controller.dart';

class FertilizerAdvisorView extends StatelessWidget {
  const FertilizerAdvisorView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<FertilizerAdvisorController>()
        ? Get.find<FertilizerAdvisorController>()
        : Get.put(FertilizerAdvisorController());

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
              isHi ? 'उर्वरक पर्ची' : 'Fertilizer Prescription',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              isHi ? 'भाकृअनुप वैज्ञानिक खुराक और बोरी गणना' : 'ICAR Scientific Dosage & Bag Calc...',
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
                isHi ? 'पर्ची साझा की जा रही है...' : 'Sharing fertilizer prescription...',
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
            // ── Top Card: "Crop & Field Specifications" (Screenshot 7) ──
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
                  // Card Header
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Color(0xFF1B5E20), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isHi ? 'फसल और खेत विनिर्देश' : 'Crop & Field Specifications',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Select Crop Dropdown
                  Text(
                    isHi ? 'फसल चुनें:' : 'Select Crop:',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                    ),
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

                  // 2. Row of Land Area & Unit
                  Row(
                    children: [
                      // Land Area Input
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHi ? 'भूमि क्षेत्र:' : 'Land Area:',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                              ),
                              child: TextField(
                                controller: c.areaController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Unit Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHi ? 'इकाई:' : 'Unit:',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                              ),
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
                                      value: c.selectedAreaUnit.value,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF616161)),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212121),
                                      ),
                                      items: c.areaUnits.map((u) {
                                        return DropdownMenuItem(
                                          value: u,
                                          child: Text(c.localizedUnit(u, isHi)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) c.selectedAreaUnit.value = val;
                                      },
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Crop Age Row + Slider (Screenshot 7)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHi ? 'फसल की आयु:' : 'Crop Age:',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w500,
                        ),
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

                  // 4. Calculate Button (Screenshot 7)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton.icon(
                          onPressed: c.isLoading.value ? null : () => c.calculateFertilizer(),
                          icon: c.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                          label: Text(
                            c.isLoading.value
                                ? (isHi ? 'गणना की जा रही है...' : 'Calculating...')
                                : (isHi ? 'पर्चे की गणना करें' : 'Calculate Prescription'),
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

            // ── Error Message if any ──
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

            // ── Prescription Results Display (Below Card) ──
            Obx(() {
              final p = c.prescription.value;
              if (p == null) return const SizedBox.shrink();

              final crop = p['crop_name'] ?? c.selectedCrop.value;
              final acres = p['calculated_acres'] ?? c.areaController.text;
              final items = p['fertilizer_items'] is List ? (p['fertilizer_items'] as List) : [];
              final splits = p['split_schedule'] is List ? (p['split_schedule'] as List) : [];
              final tips = p['soil_health_tips'] is List ? (p['soil_health_tips'] as List) : [];
              final aiExpl = p['ai_explanation'] ?? '';

              final pureNutrients = p['pure_nutrients_kg'] as Map<String, dynamic>?;
              final recType = p['recommendation_type'] ?? (isHi ? 'कृषि वैज्ञानिक संस्तुति' : 'Agronomic Recommendation (ICAR / SAU Guidelines)');
              final soilTestUsed = p['soil_test_used'] == true;
              final notice = p['notice']?.toString() ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Banner
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
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
                                recType,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                soilTestUsed
                                    ? (isHi ? '✔ मृदा परीक्षित' : '✔ Soil Tested')
                                    : (isHi ? 'अंतरिम संस्तुति' : 'Provisional'),
                                style: const TextStyle(color: Color(0xFFA5D6A7), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${c.localizedCropName(crop, isHi)} — $acres ${c.localizedUnit(c.selectedAreaUnit.value, isHi)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isHi ? 'फसल आयु: ${c.cropAgeDays.value.toInt()} दिन' : 'Crop Age: ${c.cropAgeDays.value.toInt()} Days',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pure Nutrients Requirement (N-P-K in kg)
                  if (pureNutrients != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(child: _nutrientPill(isHi ? 'नाइट्रोजन' : 'N (Nitrogen)', '${pureNutrients['N'] ?? 0} ${isHi ? "किग्रा" : "kg"}')),
                          Container(width: 1, height: 24, color: const Color(0xFFA5D6A7)),
                          Expanded(child: _nutrientPill(isHi ? 'फास्फोरस' : 'P₂O₅ (Phosphorus)', '${pureNutrients['P2O5'] ?? 0} ${isHi ? "किग्रा" : "kg"}')),
                          Container(width: 1, height: 24, color: const Color(0xFFA5D6A7)),
                          Expanded(child: _nutrientPill(isHi ? 'पोटाश' : 'K₂O (Potash)', '${pureNutrients['K2O'] ?? 0} ${isHi ? "किग्रा" : "kg"}')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Notice when soil test is unavailable
                  if (!soilTestUsed || notice.isNotEmpty) ...[
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
                              notice.isNotEmpty
                                  ? notice
                                  : (isHi
                                      ? '⚠️ प्रांतीय सामान्य उर्वरता आधारित संस्तुति: सटीक एवं किफायती पोषण प्रबंधन हेतु मृदा स्वास्थ्य कार्ड परीक्षण अवश्य करवाएं।'
                                      : '⚠️ Provisional Recommendation: Based on regional general soil fertility. For precision nutrition, use a Soil Health Card test.'),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037), height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Commercial Fertilizer Requirement Cards (Urea, DAP, MOP bag counts)
                  Text(
                    isHi ? 'आवश्यक व्यावसायिक उर्वरक (बोरी गणना):' : 'Commercial Fertilizer Bag Count:',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) => _fertilizerItemCard(item, isHi)),
                  const SizedBox(height: 16),

                  // Split Application Schedule
                  if (splits.isNotEmpty) ...[
                    Text(
                      isHi ? 'वैज्ञानिक विभाजन तालिका (कब कितना डालें):' : 'Split Application Schedule:',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 8),
                    ...splits.map((s) => _splitStageCard(s, isHi)),
                    const SizedBox(height: 16),
                  ],

                  // AI Explanation
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
                              Expanded(
                                child: Text(
                                  isHi ? 'कृषि वैज्ञानिक परामर्श:' : 'AgriShield AI Agronomic Insight:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aiExpl,
                            style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF263238)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Soil Health & Precautions
                  if (tips.isNotEmpty) ...[
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
                                isHi ? 'महत्वपूर्ण सावधानियां एवं सुझाव' : 'Key Precautions & Best Practices',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...tips.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                                    Expanded(child: Text(t.toString(), style: const TextStyle(fontSize: 12, height: 1.3))),
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

  Widget _nutrientPill(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: Color(0xFF616161)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
        ),
      ],
    );
  }

  Widget _fertilizerItemCard(dynamic item, bool isHi) {
    final name = item['name'] ?? 'Fertilizer';
    final totalKg = item['total_kg'] ?? 0;
    final bagsCount = item['bags_count'] ?? 0;
    final wholeBags = item['bags_whole_to_buy'] ?? (bagsCount is num ? bagsCount.ceil() : 0);
    final bufferKg = item['remaining_buffer_kg'] ?? 0;
    final perAcreKg = item['per_acre_kg'] ?? 0;
    final bagSize = item['bag_size_kg'] ?? 50;
    final composition = item['composition'] ?? '';
    final purpose = item['purpose'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1B5E20), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                    ),
                    if (composition.isNotEmpty)
                      Text(
                        composition,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    if (purpose.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          purpose,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1B5E20)),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$wholeBags ${isHi ? "बोरी खरीदें" : "Bags to Buy"}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isHi ? "पैकिंग" : "Size"}: $bagSize ${isHi ? "किग्रा" : "kg"}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),

          // Detail stats: Total KG, Exact bags float, and Buffer remaining
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '${isHi ? "कुल मात्रा" : "Total"}: $totalKg ${isHi ? "किग्रा" : "kg"} ($perAcreKg ${isHi ? "किग्रा" : "kg"}/${isHi ? "एकड़" : "Acre"})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF37474F)),
              ),
              Text(
                '${isHi ? "सटीक गणना" : "Exact"}: $bagsCount ${isHi ? "बोरी" : "Bags"}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF546E7A)),
              ),
              if (bufferKg > 0)
                Text(
                  '${isHi ? "शेष बफर" : "Buffer"}: $bufferKg ${isHi ? "किग्रा" : "kg"}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _splitStageCard(dynamic split, bool isHi) {
    final stage = split['stage'] ?? 'Stage';
    final fert = split['fertilizers'] ?? '';
    final method = split['method'] ?? '';
    final importance = split['importance'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFF1B5E20)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  stage,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            fert,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
          ),
          if (method.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${isHi ? "प्रयोग विधि" : "Method"}: $method',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
            ),
          ],
          if (importance.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              importance,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
