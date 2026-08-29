import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'home_page.dart';

// Deepak's packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class VerifyEmailPage extends StatefulWidget {
  final String username;
  final String email;

  const VerifyEmailPage({
    required this.username,
    required this.email,
    super.key,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmailPage> {
  final List<TextEditingController> _otpCtrllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool loadingAnimation = false;

  @override
  void dispose() {
    for (final otpCtrl in _otpCtrllers) {
      otpCtrl.dispose();
    }

    for (final fcsNde in _focusNodes) {
      fcsNde.dispose();
    }

    super.dispose();
  }

  // To track and monitor which OTP box is currently being highlighted
  // From left to right, one at a time.
  // Current Bug: can't backspace base on current index of FocusNode
  void _onCodeChange(int index, String number) {
    // For adding in new inputs
    if (number.isNotEmpty) {
      // adding rules to make sure the index is in range
      if (index < 5) {
        // Field start at index 0, then each input will run the index + 1
        _focusNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
      // For removing inputs
    } else {
      // if new input is empty, focus to previous focusNode
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  // Verify function
  Future<void> _verifyCode(BuildContext context) async {
    setState(() {
      loadingAnimation = true;
    });

    final confirmCode = _getOTPCode();
    if (confirmCode.isEmpty)
      _showDialogError(context, "Please enter verification code to register");

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: widget.username,
        confirmationCode: confirmCode,
      );

      if (result.isSignUpComplete) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text("Verfication Complete"),
              content: Text("Welcome to Travelly! You are now a register user"),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Confirm"),
                  isDefaultAction: true,
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                ),
              ],
            ),
          );
        }
      }
    } on AuthException catch (e) {
      safePrint('Error: ${e.toString()}');
      final message = e.message;
      _showDialogError(context, message);
    } finally {
      setState(() => loadingAnimation = false);
    }
  }

  // -------------------------------------FOR LATER DEVELOPMENT-------------------------------------
  // Future<void> resendCode() async {
  //   // setState(() { isLoading = true; error = null; });

  //   try {
  //     await Amplify.Auth.resendSignUpCode(username: widget.username);
  //     if (mounted) {
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   const SnackBar(content: Text('Confirmation code resent')),
  //       // );
  //       showCupertinoDialog(
  //         context: context,
  //         builder: (context) => CupertinoAlertDialog(
  //           title: const Text("Verfication Code Resent"),
  //           content: Text("Please check your email for new verfication code"),
  //           actions: [
  //             CupertinoDialogAction(
  //               child: const Text("Okay"),
  //               isDefaultAction: true,
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //             )
  //           ],
  //         )
  //       );
  //     }
  //   } on AuthException catch (e) {
  //     safePrint('Error: ${e.toString()}');
  //     final message = e.message;
  //     _showDialogError(context, message);
  //   }
  //   //finally {
  //   //   setState(() => isLoading = false);
  //   // }
  // }
  // -------------------------------------FOR LATER DEVELOPMENT-------------------------------------

  void _showDialogError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Verfication Failed"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("Okay"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Collect the digits from each otpCtrl to merge all into one combination code
  String _getOTPCode() {
    final code = _otpCtrllers.map((otpCtrl) => otpCtrl.text).join();
    // safePrint("Verification Code : ${code}");
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      loading: loadingAnimation,
      child: Column(
        children: [
          const SizedBox(height: 72),
          const Text(
            'Verify Your Email',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter the 6-digit code sent to',
            style: TextStyle(fontSize: 12, color: AppColors.greyText),
          ),
          const Text(
            'JohnDoe@email.com',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 38),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => _CodeBox(
                otpBoxController: _otpCtrllers[index],
                focusNode: _focusNodes[index],
                onChanged: (value) => _onCodeChange(index, value),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Resend Code in 26 seconds',
            style: TextStyle(fontSize: 11, color: AppColors.greyText),
          ),
          const Spacer(),
          GreenButton(
            text: 'Verify',
            // onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage())),
            onTap: () => _verifyCode(context),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final TextEditingController otpBoxController;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  // final VoidCallback? onBackspace;

  const _CodeBox({
    required this.otpBoxController,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: otpBoxController,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: null,
        onChanged: onChanged,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        // making sure the input is strictly numbers only
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
