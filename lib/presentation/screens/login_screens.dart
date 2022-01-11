import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/my_colors.dart';
import 'package:maps/constants/strings.dart';

class LoginScreens extends StatelessWidget {
  LoginScreens({Key? key}) : super(key: key);
  late String phoneNumber;
  final GlobalKey<FormState> _phoneFormKey = GlobalKey();

  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your phone number?',
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
          child: Text(
            'please enter your phone number to verify tour account',
            //  maxLines: 1,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneFormField() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.lightGray),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              generateCountryFlag() + '+20',
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.blue),
              // backgroundBlendMode:BlendMode.clear ,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "phone"),
              autofocus: true,
              autocorrect: true,
              enableSuggestions: true,
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 2.0,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter tour phone number !';
                } else if (value.length < 11) {
                  return 'Too short for a phone number !';
                }
                return null;
              },
              onSaved: (value) {
                phoneNumber = value!;
              },
            ),
          ),
        ),
      ],
    );
  }

  String generateCountryFlag() {
    String countryCode = 'eg';
    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
    return flag;
  }

  void _register(BuildContext context) {
    if (!_phoneFormKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    } else {
      Navigator.pop(context);
      _phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(phoneNumber);
    }
  }

  Widget _buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _register(context);
        },
        child: Text(
          'Next',
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

  Widget _buildPhoneNumberSubmittedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previousState, currentState) {
        // this line means .. bloc start when state change
        return previousState != currentState;
      },
      listener: (BuildContext context, PhoneAuthState state) {
        if (state is Loading) {
          return showProgressIndicator(context);
        }
        if (state is PhoneNumbersSubmitted) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpScreen, arguments: phoneNumber);
        }
        if (state is ErrorOccurred) {
          Navigator.pop(context);
          String errorMsg = (state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              //  content: Text('please ... this code not right enter your code!'),
              content: Text(errorMsg),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
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
        body: SingleChildScrollView(
          child: Form(
            key: _phoneFormKey,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroText(),
                  SizedBox(height: 50),
                  _buildPhoneFormField(),
                  SizedBox(height: 35),
                  _buildNextButton(context),
                  _buildPhoneNumberSubmittedBloc(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
