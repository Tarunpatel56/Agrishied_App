import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_controller.dart';

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F0),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState();
        if (controller.result.value == null) return _buildPlaceholder();

        final data = controller.result.value!;
        return _buildResultView(data);
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showImagePicker,
        label: const Text("Scan Crop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
      ),
    );
  }

  // ==========================================
  // LOADING STATE
  // ==========================================
  Widget _buildLoadingState() {
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
          const Text(
            "Analyzing Your Crop...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text(
            "AI is examining the image",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PLACEHOLDER (No scan yet)
  // ==========================================
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.eco, size: 60, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 24),
          const Text(
            "AgriShield AI",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap 'Scan Crop' to analyze your crop",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            "Get instant disease detection, growth analysis & more",
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RESULT VIEW
  // ==========================================
  Widget _buildResultView(data) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // 1. CROP HEADER
        _buildCropHeader(data),
        const SizedBox(height: 16),

        // 2. HEALTH SCORE BAR
        _buildHealthBar(data.healthScore, data.healthStatus),
        const SizedBox(height: 16),

        // 3. INFO GRID (Age, Stage, Harvest)
        _buildInfoGrid(data),
        const SizedBox(height: 16),

        // 4. HARVEST PREDICTION
        _buildSection(
          "🌾 Harvest Prediction",
          Color(0xFF1B5E20),
          [
            _buildDetailRow(Icons.calendar_today, "Expected Date", data.harvestDate),
            _buildDetailRow(Icons.timer, "Days Remaining", "${data.harvestDays} days"),
            _buildDetailRow(Icons.loop, "Total Lifecycle", "${data.totalLifecycle} days"),
            _buildDetailRow(Icons.check_circle_outline, "Harvest Readiness", data.harvestReadiness),
          ],
        ),
        const SizedBox(height: 12),

        // 5. FIELD ANALYSIS (Pros & Cons)
        _buildSection(
          "📊 Field Analysis",
          Colors.teal,
          [
            _buildHighlightBox("Strengths", data.pros, Colors.green),
            const SizedBox(height: 10),
            _buildHighlightBox("Issues", data.cons, Colors.orange),
          ],
        ),
        const SizedBox(height: 12),

        // 6. GROWTH ADVISORY
        _buildSection(
          "🌱 Growth Advisory",
          Colors.blue[800]!,
          [
            _buildDetailRow(Icons.science, "Nutrient Needs", data.requirements),
            const Divider(height: 20),
            _buildDetailRow(Icons.shopping_bag, "Products", data.products),
            const Divider(height: 20),
            _buildDetailRow(Icons.water_drop, "Irrigation", data.irrigationAdvice),
            const Divider(height: 20),
            _buildDetailRow(Icons.compost, "Fertilizer", data.fertilizerRecommendation),
          ],
        ),
        const SizedBox(height: 12),

        // 7. GROWTH TIPS
        _buildSection(
          "💡 Growth Tips",
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
        _buildDiseaseSection(data),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildCropHeader(data) {
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
                  data.cropName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (data.cropNameHindi.isNotEmpty)
                  Text(
                    data.cropNameHindi,
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
                    "AI Confidence: ${data.confidence}%",
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

  Widget _buildHealthBar(int score, String status) {
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
              const Text("Crop Health Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: TextStyle(color: barColor, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildInfoGrid(data) {
    return Row(
      children: [
        _infoTile("Crop Age", data.age, Icons.calendar_today, Colors.blue),
        const SizedBox(width: 8),
        _infoTile("Growth Stage", data.stage, Icons.grass, Colors.green),
        const SizedBox(width: 8),
        _infoTile("Harvest In", "${data.harvestDays}d", Icons.timer, Colors.orange),
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

  Widget _buildDiseaseSection(data) {
    final bool hasDisease = data.disease.toLowerCase() != 'no disease detected' &&
        data.disease.toLowerCase() != 'healthy' &&
        data.disease.toLowerCase() != 'n/a';

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
                hasDisease ? "⚠️ Disease Detected" : "✅ No Disease Detected",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: hasDisease ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.coronavirus, "Disease", data.disease),
          if (hasDisease) ...[
            _buildDetailRow(Icons.help_outline, "Cause", data.diseaseCause),
            _buildDetailRow(Icons.shield, "Prevention", data.diseasePrevention),
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
                  const Text(
                    "💊 Treatment",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.treatment,
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
}