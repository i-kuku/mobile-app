import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
final List<TextEditingController> _controllers = List.generate(6,(_)=>TextEditingController());
final List<FocusNode> _focusNodes = List.generate(6,(_) => FocusNode());

bool _isLoading = false;
int _resendCountdown = 60;
Timer? _timer;

@override
void initState(){
  super.initState();
  _startResendTimer();
}

@override
void dispose(){
  _timer?.cancel();
  for(var controller in _controllers){
    controller.dispose();
  }
  for(var node in _focusNodes){
    node.dispose();
  }
  super.dispose();
}

  void _startResendTimer(){
    setState(()=>_resendCountdown =60);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds:1), (timer){
      if(_resendCountdown ==0 ){
        timer.cancel();
      }else{
        setState(() =>_resendCountdown--);
      }
    });
  }
  String _getOtpString(){
    return _controllers.map((controller) => controller.text).join();
  }

Future<void> _handleDeleteAccount() async {
    final otpCode = _getOtpString();
    if (otpCode.length != 6) {
      _showSnackbar('Please enter the full 6-digit verification code.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) throw Exception('Session invalid');

      await Supabase.instance.client.auth.verifyOTP(
        email: user.email!,
        token: otpCode,
        type: OtpType.magiclink,
      );
      await Supabase.instance.client.rpc('delete_user_account');

      
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        _showSnackbar('Account successfully deleted.');
         context.go('/sign-in');
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message);
    } catch (e) {
      _showSnackbar('Invalid verification token. Please check and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendCode() async {
    if (_resendCountdown > 0) return;
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: user.email!,
        shouldCreateUser: false,
      );
      _showSnackbar('A fresh verification code has been sent.');
      _startResendTimer();
    } catch (e) {
      _showSnackbar('Error sending code: $e');
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }


  @override
  Widget build(BuildContext context) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? "your email";
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr(),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20,color: CustomColors.primary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:Icon(Icons.arrow_back_ios,color: Colors.black,),
          onPressed: (){
            context.pop();
          },
          ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('account_deletion_title'.tr(),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20,color: CustomColors.text),
            ),
            SizedBox(height: 16,),
            Text('otp_message_text'.tr() ,
            style:Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.text,fontSize: 17),
            ),
            SizedBox(height:10,),
            Text(userEmail),
            SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index){
                  return SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength:1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder:UnderlineInputBorder(
                          borderSide:BorderSide(color:Colors.grey,width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:BorderSide(color: CustomColors.primary),
                        )
                      ),
                      onChanged:(value){
                        if(value.isNotEmpty && index <5){
                          _focusNodes[index + 1].requestFocus();
                        }else if(value.isEmpty && index >0){
                          _focusNodes[index -1].requestFocus();
                        }
                      }
                    ),
                  );
                })
              
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDeleteAccount, 
                style:ElevatedButton.styleFrom(
                  backgroundColor:Colors.red[300],
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                )
                , child: _isLoading
                ? CircularProgressIndicator(color: Colors.white,)
                :Text(
                  'delete_account'.tr(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20,color:Colors.white,letterSpacing:0.6),
                )
                ,),
            ),
            SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                   Text(
                    "didn't_get_the_code".tr(),
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: _resendCountdown == 0 ? _handleResendCode : null,
                    child: Text(
                      _resendCountdown == 0 ? 'RESEND CODE' : 'RESEND IN ($_resendCountdown s)',
                      style: TextStyle(
                        color: _resendCountdown == 0 ? const Color(0xFF2E7D32) : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      )
                    )
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}