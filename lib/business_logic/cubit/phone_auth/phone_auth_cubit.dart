import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  //   verificationId--> this variable I use it when code sent me on my phone
  String? verificationId;

  PhoneAuthCubit() : super(PhoneAuthInitial());

  Future<void> submitPhoneNumber(String phoneNumber) async {
    emit(Loading());
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+2$phoneNumber',
      timeout: const Duration(seconds: 14),
      // verificationCompleted--> write my code automatic  on phone without entered it
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  //verificationCompleted: Automatic handling of the SMS code on Android devices.
  void verificationCompleted(PhoneAuthCredential credential) async {
    print('verificationCompleted');
    await signIn(credential);
  }

  //verificationFailed: Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
  void verificationFailed(FirebaseAuthException error) {
    print('verificationFailed : ${error.toString()} ');
    emit(ErrorOccurred(errorMsg: error.toString()));
  }

  //codeSent: Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
  void codeSent(String verificationId, int? resendToken) {
    print('codeSent');
    this.verificationId = verificationId;
    // emit this PhoneNumbersSubmitted() because phoneNumber I submit right
    emit(PhoneNumbersSubmitted());
  }

  // codeAutoRetrievalTimeout: Handle a timeout of when automatic SMS code handling fails.
  codeAutoRetrievalTimeout(String verificationId) {
    print('codeAutoRetrievalTimeout');
  }

  Future<void> submitOtp(String otpCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: this.verificationId!, smsCode: otpCode);
    await signIn(credential);
  }

  Future<void> signIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(PhoneOTPVerified());
    } catch (error) {
      emit(ErrorOccurred(errorMsg: error.toString()));
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  User getLoggedInUserData() {
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    return firebaseUser;
  }
}
