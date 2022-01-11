import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/my_colors.dart';
import 'package:maps/constants/strings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  final phoneNumber;
  String? otpCode;

  OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify your phone number ',
          // maxLines: 1,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: RichText(
            text: TextSpan(
              text: 'Enter your 6 digit code number sent to your ',
              style: TextStyle(color: Colors.black, fontSize: 18, height: 1.4),
              children: <TextSpan>[
                TextSpan(
                    text: '${phoneNumber}',
                    style: TextStyle(
                      color: MyColors.blue,
                      fontSize: 18,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeFields(BuildContext context) {
    return Container(
      child: PinCodeTextField(
        appContext: context,
        autoFocus: true,
        cursorColor: Colors.black,
        keyboardType: TextInputType.phone,
        length: 6,
        obscureText: false,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          borderWidth: 1,
          activeColor: MyColors.blue,
          inactiveColor: MyColors.blue,
          inactiveFillColor: Colors.white,
          activeFillColor: MyColors.liteBlue,
          disabledColor: Colors.white,
          selectedColor: MyColors.blue,
          selectedFillColor: Colors.white,
        ),
        animationDuration: Duration(milliseconds: 300),
        backgroundColor: Colors.white,
        enableActiveFill: true,
        //errorAnimationController: errorController,
        //controller: textEditingController,
        onCompleted: (submittedCode) {
          otpCode = submittedCode;
          print("Completed");
        },
        onChanged: (value) {
          print(value);
        },
      ),
    );
  }

  _logIn(BuildContext context) {
    BlocProvider.of<PhoneAuthCubit>(context).submitOtp(otpCode!);
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _logIn(context);
        },
        child: Text(
          'Verify',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(110, 50),
          primary: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  void showProgressIndicator(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  Widget _buildPhoneVerificationBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previousState, currentState) {
        // this line means .. bloc start when state change
        return previousState != currentState;
      },
      listener: (BuildContext context, PhoneAuthState state) {
        if (state is Loading) {
          return showProgressIndicator(context);
        }
        if (state is PhoneOTPVerified) {
          Navigator.pop(context);
          Navigator.of(context).popAndPushNamed(mapScreen);
        }
        if (state is ErrorOccurred) {
          // Navigator.pop(context);
          String errorMsg = (state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 5),
            ),
          );
        }
      },
      child: Container(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroText(),
                SizedBox(height: 40),
                _buildPinCodeFields(context),
                SizedBox(
                  height: 35,
                ),
                _buildVerifyButton(context),
                _buildPhoneVerificationBloc(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
