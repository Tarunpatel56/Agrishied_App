import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    currentUser.bindStream(_auth.authStateChanges());
  }

  bool get isLoggedIn => currentUser.value != null;

  // ── Sign Up ──────────────────────────────────────────────
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading(true);
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Update display name
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      currentUser.value = _auth.currentUser;

      Get.snackbar('✅ Account Created', 'Welcome to AgriShield AI!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = 'Something went wrong';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already registered';
          break;
        case 'weak-password':
          msg = 'Password is too weak (min 6 characters)';
          break;
        case 'invalid-email':
          msg = 'Invalid email address';
          break;
      }
      Get.snackbar('❌ Signup Failed', msg,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('❌ Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading(false);
    }
  }

  // ── Login ────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      Get.snackbar('✅ Welcome Back!', 'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = 'Something went wrong';
      switch (e.code) {
        case 'user-not-found':
          msg = 'No account found with this email';
          break;
        case 'wrong-password':
          msg = 'Incorrect password';
          break;
        case 'invalid-email':
          msg = 'Invalid email address';
          break;
        case 'invalid-credential':
          msg = 'Invalid email or password';
          break;
      }
      Get.snackbar('❌ Login Failed', msg,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('❌ Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading(false);
    }
  }

  // ── Forgot Password ──────────────────────────────────────
  Future<bool> forgotPassword({required String email}) async {
    isLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar('📧 Email Sent', 'Check your inbox for reset link',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = 'Something went wrong';
      if (e.code == 'user-not-found') {
        msg = 'No account found with this email';
      }
      Get.snackbar('❌ Error', msg, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('❌ Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading(false);
    }
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    Get.snackbar('👋 Logged Out', 'See you later!',
        snackPosition: SnackPosition.BOTTOM);
  }
}
