import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'home_page.dart';

// Deepak's packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmailPage>  {
  // final otp1Ctrl = TextEditingController();
  // final otp2Ctrl = TextEditingController();
  // final otp3Ctrl = TextEditingController();
  // final otp4Ctrl = TextEditingController();
  // final otp5Ctrl = TextEditingController();
  // final otp6Ctrl = TextEditingController();
  final List<TextEditingController> _otpCtrllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
  void _onCodeChange(int index, String number) {
    final List<String> inputTracker = [];

    // adding rules to make sure the index is in range and number is contains a digit
    if (number.isNotEmpty && index < 5) {
      // Field start at index 0, then each input will run the index + 1
      inputTracker.add(number);
      _focusNodes[index + 1].requestFocus();
    }

    // if over to index 6, force the input to stop focus
    if (index == 5 && number.isNotEmpty) {
      FocusScope.of(context).unfocus();
    }
    
    // if new input is empty, focus to previous focusNode
    if (number.isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }

  }

  // Collect the digits from each otpCtrl to merge all into one combination code
  String _getOTPCode() {
    return _otpCtrllers.map((otpCtrl) => otpCtrl.text).join();
  }


  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        children: [
          const SizedBox(height: 72),
          const Text('Verify Your Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Enter the 6-digit code sent to', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
          const Text('JohnDoe@email.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 38),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: List.generate(6, (index) => 
              _CodeBox(
                otpBoxController: _otpCtrllers[index],
                focusNode: _focusNodes[index],
                onChanged: (value) => _onCodeChange(index, value),
              )
            )
          ),
          const SizedBox(height: 24),
          const Text('Resend Code in 26 seconds', style: TextStyle(fontSize: 11, color: AppColors.greyText)),
          const Spacer(),
          GreenButton(
            text: 'Verify',
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage())),
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
  final VoidCallback? onBackspace;


  const _CodeBox({
    required this.otpBoxController,
    required this.focusNode,
    required this.onChanged,
    this.onBackspace,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: CupertinoTextField(
        controller: otpBoxController,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: null,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w900
        ),
      ),
    );
  }
}
