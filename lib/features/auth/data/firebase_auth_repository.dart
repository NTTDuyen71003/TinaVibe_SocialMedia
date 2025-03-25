import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/repository/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // thử đăng nhập
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      //fetch dữ liệu người dùng từ Firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      // tạo người dùng mới
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userDoc['name'],
      );
      // nếu thành công, trả về đối tượng AppUser
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // thử đăng ký
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();
      // Nếu người dùng chưa tồn tại, tạo đối tượng AppUser
      if (!userDoc.exists) {
        AppUser user = AppUser(
          // tạo người dùng mới
          uid: userCredential.user!.uid,
          email: email,
          name: name,
        );
        // Lưu dữ liệu người dùng vào Firestore
        await firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .set(user.toJson());

        // Trả về đối tượng AppUser
        return user;
      } else {
        throw Exception('Email này đã được sử dụng.');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // get current logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;

    // no user logged in..
    if (firebaseUser == null) {
      return null;
    }

    //fetch user document from firestore
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();
    //check if user doc exist
    if (!userDoc.exists) {
      return null;
    }
    // user exists
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc['name'],
    );
  }

  // Phương thức đăng nhập bằng Google
  @override
  Future<AppUser?> signInWithGoogle() async {
    // Luôn đăng xuất trước khi đăng nhập, để có thể sử dụng được account khác
    await GoogleSignIn().signOut();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Nếu người dùng hủy đăng nhập
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Lấy tên từ GoogleSignInAccount
      String name = googleUser.displayName ?? 'Người dùng';

      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      DocumentSnapshot userDoc =
          await firebaseFirestore.collection("users").doc(user!.uid).get();

      if (!userDoc.exists) {
        // Nếu người dùng chưa tồn tại, lưu thông tin vào Firestore
        AppUser appUser =
            AppUser(uid: user.uid, email: user.email!, name: name);
        await firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .set(appUser.toJson());
      }

      return AppUser(uid: user.uid, email: user.email!, name: name);
    } catch (e) {
      throw Exception("Failed to sign in with Google: $e");
    }
  }
}
