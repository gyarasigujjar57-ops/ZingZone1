import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';

const navy=Color(0xFF11152B), blue=Color(0xFF4965F5), violet=Color(0xFF7856D9), pink=Color(0xFFEF4F83), muted=Color(0xFF747B8F), line=Color(0xFFE8EAF1), pale=Color(0xFFF6F7FB);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const ZingZone());
}
void note(BuildContext c,String s)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(s),behavior:SnackBarBehavior.floating));
void page(BuildContext c,Widget w)=>Navigator.push(c,MaterialPageRoute(builder:(_)=>w));
Future<void> signInWithGoogle(BuildContext c) async {try{final googleUser=await GoogleSignIn().signIn();if(googleUser==null)return;final googleAuth=await googleUser.authentication;final credential=GoogleAuthProvider.credential(accessToken:googleAuth.accessToken,idToken:googleAuth.idToken);await FirebaseAuth.instance.signInWithCredential(credential);if(c.mounted)Navigator.pushAndRemoveUntil(c,MaterialPageRoute(builder:(_)=>const Shell()),(r)=>false);}on FirebaseAuthException catch(e){if(c.mounted)note(c,'Google sign-in failed: ${e.message??e.code}');}catch(_){if(c.mounted)note(c,'Google sign-in complete nahi hua. Firebase Console mein Google provider aur Android SHA/OAuth setup check karo.');}}
class ZingZone extends StatelessWidget {
  const ZingZone({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    title: 'Zing Zone',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.light),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: blue, width: 1.5)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFE9ECFF),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
      ),
    ),
    home: const Welcome(),
  );
}
class Welcome extends StatelessWidget {
  const Welcome({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        Positioned(
          top: -100, right: -100,
          child: Container(
            width: 310, height: 310,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x553D72FF), Color(0x003D72FF)]),
            ),
          ),
        ),
        Positioned(
          bottom: 20, left: -120,
          child: Container(
            width: 300, height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x337E5BFF), Color(0x007E5BFF)]),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: [Color(0xFF3E75FF), Color(0xFF7856D9)],
                            ),
                            boxShadow: const [BoxShadow(color: Color(0x333E75FF), blurRadius: 22, offset: Offset(0, 8))],
                          ),
                          child: const Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 29),
                        ),
                        const SizedBox(width: 11),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ZING ZONE', style: TextStyle(color: navy, fontWeight: FontWeight.w900, letterSpacing: 2.2, fontSize: 18)),
                            SizedBox(height: 2),
                            Text('YOUR EVERYDAY AI WORKSPACE', style: TextStyle(color: muted, fontWeight: FontWeight.w700, letterSpacing: 1.05, fontSize: 8)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFDDE6FF)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 15, color: blue),
                          SizedBox(width: 7),
                          Text('ONE WORKSPACE. MORE POSSIBILITIES.', style: TextStyle(color: blue, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your next task,\na smarter way.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navy, fontSize: 37, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -1.3),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'A personal AI workspace for everyday questions, documents and public-service guidance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, height: 1.6, fontSize: 14),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE6EAF5)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0D263D78), blurRadius: 32, offset: Offset(0, 15)),
                          BoxShadow(color: Color(0x0A4D70FF), blurRadius: 12, spreadRadius: 1),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4, color: navy, fontSize: 11)),
                          const SizedBox(height: 15),
                          OutlinedButton.icon(
                            onPressed: () => signInWithGoogle(c),
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 29),
                            label: const Text('Continue with Google'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              foregroundColor: navy,
                              side: const BorderSide(color: Color(0xFFDDE2EE)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 11),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              gradient: const LinearGradient(colors: [Color(0xFF3568F5), Color(0xFF6955E8)]),
                              boxShadow: const [BoxShadow(color: Color(0x333E67F5), blurRadius: 18, offset: Offset(0, 7))],
                            ),
                            child: FilledButton.icon(
                              onPressed: () => page(c, const MobileLogin()),
                              icon: const Icon(Icons.phone_iphone_rounded),
                              label: const Text('Continue with mobile'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          TextButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const Shell()), (r) => false),
                            child: const Text('Explore as guest', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 14, color: muted),
                        SizedBox(width: 6),
                        Flexible(child: Text('You stay in control of your information and final submissions.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 10, height: 1.4))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
class MobileLogin extends StatefulWidget{const MobileLogin({super.key});@override State<MobileLogin> createState()=>_MobileLoginState();}
class _MobileLoginState extends State<MobileLogin>{final phone=TextEditingController();bool loading=false;@override void dispose(){phone.dispose();super.dispose();}Future<void> sendCode() async {final digits=phone.text.trim();if(!RegExp(r'^[0-9]{10}$').hasMatch(digits)){note(context,'Enter a valid 10-digit mobile number.');return;}setState(()=>loading=true);try{await FirebaseAuth.instance.verifyPhoneNumber(phoneNumber:'+91$digits',timeout:const Duration(seconds:60),verificationCompleted:(credential)async{try{await FirebaseAuth.instance.signInWithCredential(credential);if(mounted)Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const Shell()),(r)=>false);}on FirebaseAuthException catch(e){if(mounted)note(context,'Sign-in failed: ${e.message??e.code}');}},verificationFailed:(e){if(mounted)note(context,'SMS verification failed: ${e.message??e.code}');},codeSent:(verificationId,resendToken){if(mounted)page(context,PhoneOtp(phone:digits,verificationId:verificationId));},codeAutoRetrievalTimeout:(verificationId){});}on FirebaseAuthException catch(e){if(mounted)note(context,'Could not send OTP: ${e.message??e.code}');}finally{if(mounted)setState(()=>loading=false);}}@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Mobile sign in')),body:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:24),const Icon(Icons.shield_outlined,color:blue,size:46),const SizedBox(height:16),const Text('Your number, your account',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900,color:navy)),const Text('Firebase will send a real SMS verification code.',style:TextStyle(color:muted)),const SizedBox(height:20),TextField(controller:phone,keyboardType:TextInputType.phone,maxLength:10,decoration:const InputDecoration(prefixText:'+91  ',labelText:'Mobile number')),const SizedBox(height:10),FilledButton(onPressed:loading?null:sendCode,style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(50),backgroundColor:blue),child:Text(loading?'Sending OTP…':'Send verification code'))])));}
class PhoneOtp extends StatefulWidget{final String phone,verificationId;const PhoneOtp({super.key,required this.phone,required this.verificationId});@override State<PhoneOtp> createState()=>_PhoneOtpState();}
class _PhoneOtpState extends State<PhoneOtp>{final code=TextEditingController();bool loading=false;@override void dispose(){code.dispose();super.dispose();}Future<void> verify() async {if(code.text.trim().length!=6){note(context,'Enter the 6-digit SMS code.');return;}setState(()=>loading=true);try{final credential=PhoneAuthProvider.credential(verificationId:widget.verificationId,smsCode:code.text.trim());await FirebaseAuth.instance.signInWithCredential(credential);if(mounted)Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const Shell()),(r)=>false);}on FirebaseAuthException catch(e){if(mounted)note(context,'Verification failed: ${e.message??e.code}');}finally{if(mounted)setState(()=>loading=false);}}@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Verify number')),body:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:20),const Text('Check your messages',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),Text('Enter the code sent to +91 ${widget.phone}.',style:const TextStyle(color:muted)),const SizedBox(height:20),TextField(controller:code,maxLength:6,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'6-digit SMS code')),FilledButton(onPressed:loading?null:verify,style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(50),backgroundColor:blue),child:Text(loading?'Verifying…':'Verify and continue'))])));}
class Shell extends StatefulWidget{const Shell({super.key});@override State<Shell> createState()=>_ShellState();}
class _ShellState extends State<Shell>{int tab=0;@override Widget build(BuildContext c)=>Scaffold(body:IndexedStack(index:tab,children:const[ChatPage(),StorePage(),RewardsPage(),ProfilePage()]),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[NavigationDestination(icon:Icon(Icons.chat_bubble_outline),selectedIcon:Icon(Icons.chat_bubble),label:'AI Chat'),NavigationDestination(icon:Icon(Icons.shopping_bag_outlined),selectedIcon:Icon(Icons.shopping_bag),label:'Store'),NavigationDestination(icon:Icon(Icons.card_giftcard_outlined),selectedIcon:Icon(Icons.card_giftcard),label:'Rewards'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'Profile')]));}
class ChatPage extends StatefulWidget{const ChatPage({super.key});@override State<ChatPage> createState()=>_ChatPageState();}
class _ChatPageState extends State<ChatPage>{final input=TextEditingController();final msgs=<List<String>>[];bool sending=false;@override void dispose(){input.dispose();super.dispose();}Future<void> send([String? preset]) async {final s=(preset??input.text).trim();if(s.isEmpty||sending)return;setState((){msgs.add(['user',s]);sending=true;});input.clear();try{final recent=msgs.where((m)=>m[0]=='user'||m[0]=='ai').toList();final callable=FirebaseFunctions.instanceFor(region:'asia-south1').httpsCallable('askZingAI');final result=await callable.call(<String,dynamic>{'messages':recent.map((m)=>{'role':m[0]=='ai'?'model':'user','text':m[1]}).toList()});final data=result.data;if(data is! Map || data['answer'] is! String || (data['answer'] as String).trim().isEmpty){throw Exception('empty-answer');}if(mounted)setState(()=>msgs.add(['ai',(data['answer'] as String).trim()]));}on FirebaseFunctionsException catch(e){final message=switch(e.code){'unauthenticated'=>'AI chat ke liye pehle Google ya mobile number se sign in karo. Guest mode mein live AI chat available nahi hai.','failed-precondition'=>'AI backend ka Gemini key abhi configure nahi hua hai.','not-found'=>'AI backend abhi deploy nahi hua hai.','unavailable'=>'AI abhi busy hai. Thodi der baad dobara try karo.','permission-denied'=>'AI request ko permission nahi mili. Backend configuration check karni hogi.',_=>'AI se connect nahi ho paya (${e.code}). Backend setup aur network check karna hoga.'};if(mounted)setState(()=>msgs.add(['ai',message]));}catch(_){if(mounted)setState(()=>msgs.add(['ai','Abhi Zing AI se jawab nahi mila. Internet check karke dobara try karo.']));}finally{if(mounted)setState(()=>sending=false);}}Widget suggestion(String title,String subtitle,IconData icon,String promptText)=>Card(color:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17),side:const BorderSide(color:line)),child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFEDF0FF),child:Icon(icon,color:blue)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w800,color:navy)),subtitle:Text(subtitle,style:const TextStyle(fontSize:11,color:muted)),trailing:const Icon(Icons.arrow_forward_ios,size:14),onTap:()=>send(promptText)));@override Widget build(BuildContext c)=>Scaffold(backgroundColor:Colors.white,drawer:Drawer(child:SafeArea(child:Column(children:[const Padding(padding:EdgeInsets.all(18),child:Row(children:[Icon(Icons.all_inclusive,color:blue,size:30),SizedBox(width:10),Text('ZING ZONE',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.5,color:navy,fontSize:17))])),const Divider(height:1),ListTile(leading:const Icon(Icons.add_comment_outlined,color:blue),title:const Text('New chat'),onTap:(){Navigator.pop(c);if(msgs.isNotEmpty)ChatMemory.history.insert(0,msgs.map((m)=>'${m[0]=='user'?'You':'Zing AI'}: ${m[1]}').join('\\n'));setState(()=>msgs.clear());}),ListTile(leading:const Icon(Icons.history,color:blue),title:const Text('Chat history'),onTap:(){Navigator.pop(c);page(c,const ChatHistory());}),ListTile(leading:const Icon(Icons.drafts_outlined,color:blue),title:const Text('Drafts'),onTap:(){Navigator.pop(c);page(c,const DraftsPage());}),const Divider(),ListTile(leading:const Icon(Icons.settings_outlined,color:blue),title:const Text('Settings'),onTap:(){Navigator.pop(c);page(c,const AppSettingsPage());}),const Spacer(),const Padding(padding:EdgeInsets.all(16),child:Text('Personal AI workspace • Zing Zone',style:TextStyle(fontSize:11,color:muted)))]))),body:SafeArea(child:Column(children:[Padding(padding:const EdgeInsets.fromLTRB(15,13,8,12),child:Row(children:[Builder(builder:(ctx)=>IconButton(tooltip:'Open chat drawer',onPressed:()=>Scaffold.of(ctx).openDrawer(),icon:const Icon(Icons.menu_rounded,color:navy,size:26))),Container(width:40,height:40,decoration:BoxDecoration(gradient:const LinearGradient(colors:[blue,violet]),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.auto_awesome,color:Colors.white)),const SizedBox(width:8),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Zing AI',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:navy)),Text('Your personal assistant',style:TextStyle(fontSize:11,color:muted))])),IconButton(tooltip:'Notifications',onPressed:()=>page(c,const NotificationsPage()),icon:const Icon(Icons.notifications_none,color:navy)),IconButton(tooltip:'Premium',onPressed:()=>page(c,const PremiumPage()),icon:const Icon(Icons.workspace_premium_outlined,color:violet)),TokenBalanceBadge(onTap:()=>page(c,const TokenPage())) ])),const Divider(height:1,color:line),Expanded(child:msgs.isEmpty
      ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 38, color: blue),
                SizedBox(height: 14),
                Text('What would you like help with?', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy)),
                SizedBox(height: 8),
                Text('Type your task below. Zing AI will guide you from the same chat.',
                  textAlign: TextAlign.center, style: TextStyle(color: muted, height: 1.5)),
              ],
            ),
          ),
        )
      : ListView(padding:const EdgeInsets.all(16),children:msgs.map((m){final user=m[0]=='user';return Align(alignment:user?Alignment.centerRight:Alignment.centerLeft,child:Container(constraints:const BoxConstraints(maxWidth:330),margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:user?blue:const Color(0xFFF1F3F8),borderRadius:BorderRadius.only(topLeft:const Radius.circular(19),topRight:const Radius.circular(19),bottomLeft:Radius.circular(user?19:5),bottomRight:Radius.circular(user?5:19))),child:Text(m[1],style:TextStyle(color:user?Colors.white:navy,height:1.5,fontSize:14))));}).toList())),Container(padding:const EdgeInsets.fromLTRB(9,8,9,12),decoration:const BoxDecoration(color:Colors.white,boxShadow:[BoxShadow(color:Color(0x10000000),blurRadius:15,offset:Offset(0,-4))]),child:Column(children:[Row(children:[IconButton(onPressed:()=>note(c,'File attachment needs integration.'),icon:const Icon(Icons.add_circle_outline)),Expanded(child:TextField(controller:input,minLines:1,maxLines:5,onSubmitted:(_)=>send(),decoration:InputDecoration(hintText:'Message Zing AI…',filled:true,fillColor:pale,border:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:BorderSide.none)))),Container(decoration:BoxDecoration(color:blue,borderRadius:BorderRadius.circular(15)),child:IconButton(onPressed:send,icon:const Icon(Icons.arrow_upward,color:Colors.white)))]),Text(sending?'Zing AI is thinking…':'Connected AI replies require sign-in and a deployed backend.',style:const TextStyle(fontSize:10,color:muted))]))])));}
class ChatMemory {
  static final List<String> drafts = <String>[];
  static final List<String> history = <String>[];
}

class ChatHistory extends StatelessWidget {
  const ChatHistory({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Chat history')),
    body: ChatMemory.history.isEmpty
      ? const Center(child: Text('No saved chats yet. Use the three-dot menu to save a conversation.'))
      : ListView.builder(
          itemCount: ChatMemory.history.length,
          itemBuilder: (context, index) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
            title: Text('Conversation ${ChatMemory.history.length - index}'),
            subtitle: Text(ChatMemory.history[index], maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => note(context, 'Conversation preview is available in this local session.'),
          ),
        ),
  );
}

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key});
  @override State<DraftsPage> createState() => _DraftsPageState();
}
class _DraftsPageState extends State<DraftsPage> {
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Chat drafts')),
    body: ChatMemory.drafts.isEmpty
      ? const Center(child: Text('No drafts saved yet. Open AI Chat → ⋮ → Save draft.'))
      : ListView.builder(
          itemCount: ChatMemory.drafts.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.drafts_outlined, color: blue),
            title: Text(ChatMemory.drafts[index], maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              tooltip: 'Delete draft',
              icon: const Icon(Icons.delete_outline),
              onPressed: () { setState(() => ChatMemory.drafts.removeAt(index)); },
            ),
          ),
        ),
  );
}
class ShopItem{final String name,category,price,old,discount;final IconData icon;final Color color;const ShopItem(this.name,this.category,this.price,this.old,this.discount,this.icon,this.color);}
const catalog=<ShopItem>[ShopItem('Everyday kurti','Women','₹299','₹599','50% OFF',Icons.checkroom,Color(0xFFFFE7EF)),ShopItem('Printed suit set','Women','₹499','₹899','44% OFF',Icons.dry_cleaning,Color(0xFFF4E5FF)),ShopItem('Casual sneakers','Footwear','₹399','₹799','50% OFF',Icons.directions_run,Color(0xFFE4F1FF)),ShopItem('Kitchen storage set','Home','₹249','₹449','44% OFF',Icons.kitchen,Color(0xFFFFEBD9)),ShopItem('Skincare kit','Beauty','₹199','₹349','43% OFF',Icons.spa,Color(0xFFE2F8EC)),ShopItem('Fashion jewellery','Jewellery','₹149','₹299','50% OFF',Icons.diamond,Color(0xFFFFF0CF)),ShopItem('Smart accessories','Electronics','₹349','₹699','50% OFF',Icons.headphones,Color(0xFFE9E8FF)),ShopItem('Kids daily wear','Kids','₹229','₹399','43% OFF',Icons.child_care,Color(0xFFFFE7D8)),ShopItem('Men casual shirt','Men','₹329','₹599','45% OFF',Icons.checkroom,Color(0xFFE0F4F1)),ShopItem('Home decor lamp','Home','₹399','₹799','50% OFF',Icons.light,Color(0xFFFFEAD6))];
class StorePage extends StatefulWidget{const StorePage({super.key});@override State<StorePage> createState()=>_StorePageState();}
class _StorePageState extends State<StorePage>{final search=TextEditingController();String category='For You';final saved=<String>{};final cart=<ShopItem>[];final cats=['For You','Women','Men','Kids','Home','Beauty','Footwear','Jewellery','Electronics'];@override void dispose(){search.dispose();super.dispose();}void like(String name){setState(()=>saved.contains(name)?saved.remove(name):saved.add(name));} @override Widget build(BuildContext c){final items=catalog.where((p)=>(category=='For You'||p.category==category)&&(p.name+' '+p.category).toLowerCase().contains(search.text.toLowerCase())).toList();return Scaffold(backgroundColor:Colors.white,body:SafeArea(child:CustomScrollView(slivers:[SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(15,13,8,9),child:Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ZING ZONE STORE',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,letterSpacing:.5,color:navy)),Text('Everyday finds, made delightful',style:TextStyle(fontSize:11,color:muted))])),IconButton(onPressed:()=>page(c,WishlistScreen(items:catalog.where((p)=>saved.contains(p.name)).toList())),icon:Badge(isLabelVisible:saved.isNotEmpty,label:Text(saved.length.toString()),child:const Icon(Icons.favorite_border))),IconButton(onPressed:()=>page(c,CartScreen(items:List.of(cart))),icon:Badge(isLabelVisible:cart.isNotEmpty,label:Text(cart.length.toString()),child:const Icon(Icons.shopping_bag_outlined)))]))),SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:TextField(controller:search,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Search products, categories and more',prefixIcon:const Icon(Icons.search),filled:true,fillColor:pale,border:OutlineInputBorder(borderRadius:BorderRadius.circular(15),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(15),borderSide:BorderSide.none)))),),SliverToBoxAdapter(child:SizedBox(height:53,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),children:cats.map((s)=>Padding(padding:const EdgeInsets.symmetric(horizontal:4),child:ChoiceChip(label:Text(s),selected:category==s,onSelected:(_)=>setState(()=>category=s),selectedColor:const Color(0xFFFFE5ED),side:BorderSide(color:category==s?pink:line),labelStyle:TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:category==s?pink:navy)))).toList()))),SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(14,8,14,14),child:Container(height:168,padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[Color(0xFF241638),Color(0xFF8C315F),Color(0xFFFF8F9F)])),child:Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('BIG STYLE.\\nSMART FINDS.',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:25,height:1.05)),SizedBox(height:8),Text('Find your everyday favourites',style:TextStyle(color:Colors.white70,fontSize:11)),Spacer(),Text('DISCOVER NOW  →',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:11))])),const Icon(Icons.shopping_bag_rounded,size:72,color:Color(0xBFFFFFFF))])))),SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.symmetric(horizontal:15),child:Row(children:[const Expanded(child:Text('Discover products',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:navy))),Text(items.length.toString()+' items',style:const TextStyle(fontSize:11,color:muted))]))),SliverPadding(padding:const EdgeInsets.all(10),sliver:SliverGrid(delegate:SliverChildBuilderDelegate((ctx,i){final p=items[i];final isSaved=saved.contains(p.name);return InkWell(onTap:()=>page(c,ProductScreen(item:p,isSaved:isSaved,onLike:()=>like(p.name),onAdd:(){setState(()=>cart.add(p));})),borderRadius:BorderRadius.circular(15),child:Container(clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:Colors.white,border:Border.all(color:line),borderRadius:BorderRadius.circular(15)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Stack(children:[Container(width:double.infinity,color:p.color,child:Center(child:Icon(p.icon,size:62,color:const Color(0xFF655D7C)))),Positioned(left:6,top:6,child:Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:4),decoration:BoxDecoration(color:const Color(0xFF16865D),borderRadius:BorderRadius.circular(5)),child:Text(p.discount,style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w900)))),Positioned(right:0,top:0,child:IconButton(onPressed:()=>like(p.name),icon:Icon(isSaved?Icons.favorite:Icons.favorite_border,color:isSaved?pink:navy,size:20)))])),Padding(padding:const EdgeInsets.fromLTRB(8,7,8,8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:navy)),const SizedBox(height:4),Row(children:[Text(p.price,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900,color:navy)),const SizedBox(width:5),Expanded(child:Text(p.old,style:const TextStyle(fontSize:10,color:muted,decoration:TextDecoration.lineThrough)))]),const SizedBox(height:4),const Row(children:[Icon(Icons.star,color:Color(0xFFFFB72B),size:13),Text(' 4.2',style:TextStyle(fontSize:10,color:muted)),Spacer(),Text('Demo offer',style:TextStyle(fontSize:9,color:Color(0xFF16865D)))])]))])));},childCount:items.length),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,mainAxisSpacing:9,crossAxisSpacing:9,mainAxisExtent:246))),if(items.isEmpty)const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.all(30),child:Center(child:Text('No matching products.')))),const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.all(14),child:Text('Demo catalogue: prices, ratings, offers and delivery are illustrative, not live merchant data. Checkout is not active.',style:TextStyle(fontSize:10,color:muted))))])));}
}
Future<void> _openMarketplace(BuildContext c, String market, String productName) async {
  final query = Uri.encodeComponent(productName);
  final url = market == 'Meesho'
      ? Uri.parse('https://www.meesho.com/search?q=$query')
      : market == 'Flipkart'
          ? Uri.parse('https://www.flipkart.com/search?q=$query')
          : Uri.parse('https://www.amazon.in/s?k=$query');
  try {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && c.mounted) note(c, 'Could not open $market. Check your internet connection.');
  } catch (_) {
    if (c.mounted) note(c, 'Could not open $market right now.');
  }
}

class ProductScreen extends StatelessWidget{final ShopItem item;final bool isSaved;final VoidCallback onLike,onAdd;const ProductScreen({super.key,required this.item,required this.isSaved,required this.onLike,required this.onAdd});@override Widget build(BuildContext c)=>Scaffold(backgroundColor:Colors.white,appBar:AppBar(title:const Text('Product details'),actions:[IconButton(onPressed:()=>note(c,'Share feature needs integration.'),icon:const Icon(Icons.share_outlined))]),body:ListView(padding:const EdgeInsets.all(16),children:[Container(height:275,decoration:BoxDecoration(color:item.color,borderRadius:BorderRadius.circular(23)),child:Icon(item.icon,size:105,color:navy)),const SizedBox(height:16),Text(item.name,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),const SizedBox(height:8),Row(children:[Text(item.price,style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(width:10),Text(item.old,style:const TextStyle(color:muted,decoration:TextDecoration.lineThrough)),const SizedBox(width:8),Text(item.discount,style:const TextStyle(color:Color(0xFF16865D),fontWeight:FontWeight.w800))]),const SizedBox(height:8),const Text('⭐ 4.2 • demo rating',style:TextStyle(color:muted)),const Divider(height:28),Text(item.category+' • Everyday pick',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const Text('Size/colour variants, verified stock, seller, delivery ETA and return terms will come from merchant integration.',style:const TextStyle(color:muted,height:1.5)),const SizedBox(height:15),OutlinedButton.icon(onPressed:onLike,icon:Icon(isSaved?Icons.favorite:Icons.favorite_border),label:Text(isSaved?'Saved to wishlist':'Add to wishlist'),style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(48))),const SizedBox(height:8),FilledButton.icon(onPressed:(){onAdd();note(c,'Added to demo cart.');},icon:const Icon(Icons.shopping_bag_outlined),label:const Text('Add to cart'),style:FilledButton.styleFrom(backgroundColor:pink,minimumSize:const Size.fromHeight(52))),const SizedBox(height:10),
    FilledButton.icon(
      onPressed: () => _openMarketplace(c, 'Meesho', item.name),
      icon: const Icon(Icons.open_in_new),
      label: const Text('Buy on Meesho'),
      style: FilledButton.styleFrom(backgroundColor: Color(0xFF9C276B), minimumSize: const Size.fromHeight(50)),
    ),
    const SizedBox(height:8),
    OutlinedButton.icon(
      onPressed: () => _openMarketplace(c, 'Flipkart', item.name),
      icon: const Icon(Icons.shopping_cart_outlined),
      label: const Text('Find on Flipkart'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
    const SizedBox(height:8),
    OutlinedButton.icon(
      onPressed: () => _openMarketplace(c, 'Amazon', item.name),
      icon: const Icon(Icons.open_in_new),
      label: const Text('Find on Amazon'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
    const SizedBox(height:10),
    const Text('These buttons open marketplace search results. Final price, seller, stock, delivery and payment are handled by that marketplace—not by Zing Zone.',style:TextStyle(fontSize:10,color:muted))]));}
class WishlistScreen extends StatelessWidget{final List<ShopItem> items;const WishlistScreen({super.key,required this.items});@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('My wishlist')),body:items.isEmpty?const Center(child:Text('Wishlist is empty. Tap a product heart to save it.')):ListView(children:items.map((p)=>ListTile(leading:Container(width:52,height:52,decoration:BoxDecoration(color:p.color,borderRadius:BorderRadius.circular(12)),child:Icon(p.icon)),title:Text(p.name),subtitle:Text(p.price),trailing:const Icon(Icons.favorite,color:pink))).toList()));}
class CartScreen extends StatefulWidget{final List<ShopItem> items;const CartScreen({super.key,required this.items});@override State<CartScreen> createState()=>_CartScreenState();}
class _CartScreenState extends State<CartScreen>{@override Widget build(BuildContext c){final total=widget.items.fold<int>(0,(s,p)=>s+(int.tryParse(p.price.replaceAll('₹',''))??0));return Scaffold(appBar:AppBar(title:const Text('My bag')),body:widget.items.isEmpty?const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.shopping_bag_outlined,size:58,color:blue),SizedBox(height:12),Text('Your bag is waiting',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900)),Text('Products you add will appear here.',style:TextStyle(color:muted))])):Column(children:[Expanded(child:ListView(children:widget.items.asMap().entries.map((e)=>ListTile(leading:Container(width:52,height:52,decoration:BoxDecoration(color:e.value.color,borderRadius:BorderRadius.circular(12)),child:Icon(e.value.icon)),title:Text(e.value.name),subtitle:Text(e.value.price),trailing:IconButton(onPressed:()=>setState(()=>widget.items.removeAt(e.key)),icon:const Icon(Icons.delete_outline)))).toList())),Container(color:Colors.white,padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text('Subtotal: ₹'+total.toString(),style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:9),FilledButton(onPressed:()=>note(c,'Checkout/payment is not connected yet.'),style:FilledButton.styleFrom(backgroundColor:pink),child:const Text('Continue to checkout')),const Text('Demo cart only • no payment is collected.',style:TextStyle(fontSize:10,color:muted))]))]));}}
class RewardsPage extends StatelessWidget{const RewardsPage({super.key});@override Widget build(BuildContext c)=>Scaffold(body:SafeArea(child:ListView(padding:const EdgeInsets.all(17),children:[const Text('ZING ZONE CLUB',style:TextStyle(fontSize:10,letterSpacing:1.4,fontWeight:FontWeight.w900,color:muted)),const SizedBox(height:8),const Text('Your little wins\\nadd up.',style:TextStyle(fontSize:31,fontWeight:FontWeight.w900,height:1.05,color:navy)),const SizedBox(height:17),Container(padding:const EdgeInsets.all(21),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF171B43),Color(0xFF6546C6),Color(0xFFAB579D)])),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(Icons.workspace_premium,color:Color(0xFFFFD98A),size:30),Spacer(),Text('MEMBER LEVEL 01',style:TextStyle(color:Colors.white70,fontSize:10,fontWeight:FontWeight.w900))]),SizedBox(height:16),Text('0 points',style:TextStyle(color:Colors.white,fontSize:32,fontWeight:FontWeight.w900)),Text('DEMO BALANCE • NOT CASH',style:TextStyle(color:Colors.white70,fontSize:10)),SizedBox(height:13),ClipRRect(borderRadius:BorderRadius.all(Radius.circular(9)),child:LinearProgressIndicator(value:.15,minHeight:6,backgroundColor:Colors.white24,color:Color(0xFFFFD98A))),SizedBox(height:8),Text('Earn points through verified activities',style:TextStyle(color:Colors.white70,fontSize:11))])),const SizedBox(height:15),Row(children:[Expanded(child:_RewardStat(icon:Icons.local_fire_department,title:'Daily streak',value:'0 days')),const SizedBox(width:9),Expanded(child:_RewardStat(icon:Icons.emoji_events,title:'Badges',value:'0 earned'))]),const SizedBox(height:20),const Text('WAYS TO EARN',style:TextStyle(fontSize:11,letterSpacing:1.2,fontWeight:FontWeight.w900,color:muted)),const SizedBox(height:7),_RewardRow(icon:Icons.calendar_month,title:'Daily check-in',sub:'Build a daily streak',action:'Check in',onTap:()=>note(c,'Demo only: verified daily check-in needs backend.')), _RewardRow(icon:Icons.flag_outlined,title:'Missions & challenges',sub:'Complete eligible activities',action:'Explore',onTap:()=>page(c,const RewardDetail(title:'Missions & challenges'))),_RewardRow(icon:Icons.people_outline,title:'Invite friends',sub:'Referral rewards after verification',action:'Invite',onTap:()=>note(c,'Referral links and attribution need backend.')),const SizedBox(height:18),const Text('YOUR REWARDS',style:TextStyle(fontSize:11,letterSpacing:1.2,fontWeight:FontWeight.w900,color:muted)),_RewardRow(icon:Icons.redeem,title:'Reward catalogue',sub:'Browse redemption options',action:'Browse',onTap:()=>page(c,const RewardDetail(title:'Reward catalogue'))),_RewardRow(icon:Icons.receipt_long,title:'Points & transaction history',sub:'Earned, pending and redeemed',action:'View',onTap:()=>page(c,const RewardDetail(title:'Points history'))),const SizedBox(height:10),const Text('Rewards are a UI preview. No points, cash, or payouts are actually issued.',style:TextStyle(fontSize:10,color:muted))])));}
class _RewardStat extends StatelessWidget{final IconData icon;final String title,value;const _RewardStat({required this.icon,required this.title,required this.value});@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:pink),const SizedBox(height:9),Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:navy)),Text(title,style:const TextStyle(fontSize:11,color:muted))]));}
class _RewardRow extends StatelessWidget{final IconData icon;final String title,sub,action;final VoidCallback onTap;const _RewardRow({required this.icon,required this.title,required this.sub,required this.action,required this.onTap});@override Widget build(BuildContext c)=>Card(color:Colors.white,elevation:0,margin:const EdgeInsets.only(top:7),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),side:const BorderSide(color:line)),child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFFFEAF0),child:Icon(icon,color:pink)),title:Text(title,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800,color:navy)),subtitle:Text(sub,style:const TextStyle(fontSize:10,color:muted)),trailing:Text(action,style:const TextStyle(color:blue,fontWeight:FontWeight.w800,fontSize:11)),onTap:onTap));}
class RewardDetail extends StatelessWidget{final String title;const RewardDetail({super.key,required this.title});@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(title)),body:Center(child:Padding(padding:const EdgeInsets.all(25),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.workspace_premium,size:55,color:violet),const SizedBox(height:15),Text(title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('This area is ready for the real rewards service. Until backend verification is added, no points or payouts are created.',textAlign:TextAlign.center,style:TextStyle(color:muted,height:1.5))]))));}
class ProfilePage extends StatelessWidget{const ProfilePage({super.key});@override Widget build(BuildContext c)=>Scaffold(body:SafeArea(child:ListView(padding:const EdgeInsets.all(17),children:[const Text('YOUR ACCOUNT',style:TextStyle(fontSize:10,letterSpacing:1.3,fontWeight:FontWeight.w900,color:muted)),const SizedBox(height:8),const Text('Profile & settings',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900,color:navy)),const SizedBox(height:15),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(23),gradient:const LinearGradient(colors:[Color(0xFF182247),Color(0xFF5947A6)])),child:Row(children:[const CircleAvatar(radius:29,backgroundColor:Colors.white24,child:Icon(Icons.person,color:Colors.white,size:31)),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Welcome to Zing Zone',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:16)),SizedBox(height:4),Text('Guest account • sign-in not completed',style:TextStyle(color:Colors.white70,fontSize:10))])),IconButton(onPressed:()=>page(c,const PlainPage(title:'Edit profile')),icon:const Icon(Icons.edit_outlined,color:Colors.white))])),const SizedBox(height:19),const Text('MY ACTIVITY',style:TextStyle(fontSize:10,letterSpacing:1.2,fontWeight:FontWeight.w900,color:muted)),_ProfileRow(icon:Icons.assignment_outlined,title:'My applications',sub:'Drafts, submitted forms and status',onTap:()=>page(c,const PlainPage(title:'My applications'))),_ProfileRow(icon:Icons.folder_copy_outlined,title:'Document vault',sub:'Your documents and expiry reminders',onTap:()=>page(c,const PlainPage(title:'Document vault'))),const SizedBox(height:15),const Text('WALLET & PREFERENCES',style:TextStyle(fontSize:10,letterSpacing:1.2,fontWeight:FontWeight.w900,color:muted)),_ProfileRow(icon:Icons.account_balance_wallet_outlined,title:'Wallet & earning hub',sub:'Balance, transactions and withdrawals',onTap:()=>page(c,const WalletPage())),_ProfileRow(icon:Icons.language,title:'Language & accessibility',sub:'Language, text size and assistance',onTap:()=>page(c,const AppSettingsPage())),_ProfileRow(icon:Icons.notifications_none,title:'Notifications',sub:'Alerts and preferences',onTap:()=>page(c,const NotificationsPage())),_ProfileRow(icon:Icons.lock_outline,title:'Privacy & security',sub:'Permissions and account protection',onTap:()=>page(c,const PlainPage(title:'Privacy & security'))),_ProfileRow(icon:Icons.support_agent,title:'Help & support',sub:'FAQs and contact support',onTap:()=>page(c,const PlainPage(title:'Help & support'))),_ProfileRow(icon:Icons.info_outline,title:'About Zing Zone',sub:'App version and policies',onTap:()=>page(c,const PlainPage(title:'About Zing Zone'))),const SizedBox(height:10),OutlinedButton.icon(onPressed:()=>Navigator.pushAndRemoveUntil(c,MaterialPageRoute(builder:(_)=>const Welcome()),(r)=>false),icon:const Icon(Icons.logout),label:const Text('Sign out / back to welcome')),const SizedBox(height:8),const Text('Profile data and wallet are demo-only until secure authentication and backend are connected.',textAlign:TextAlign.center,style:TextStyle(fontSize:10,color:muted))])));}
class _ProfileRow extends StatelessWidget{final IconData icon;final String title,sub;final VoidCallback onTap;const _ProfileRow({required this.icon,required this.title,required this.sub,required this.onTap});@override Widget build(BuildContext c)=>Card(color:Colors.white,elevation:0,margin:const EdgeInsets.only(top:6),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15),side:const BorderSide(color:line)),child:ListTile(leading:Container(width:39,height:39,decoration:BoxDecoration(color:const Color(0xFFEDF0FF),borderRadius:BorderRadius.circular(12)),child:Icon(icon,color:blue,size:21)),title:Text(title,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800,color:navy)),subtitle:Text(sub,style:const TextStyle(fontSize:10,color:muted)),trailing:const Icon(Icons.chevron_right,color:muted),onTap:onTap));}
class PlainPage extends StatelessWidget{final String title;const PlainPage({super.key,required this.title});@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(title)),body:Center(child:Padding(padding:const EdgeInsets.all(24),child:Text(title+'\\n\\nThis screen is part of the frontend prototype. Secure storage, live data and actions will be connected in the backend phase.',textAlign:TextAlign.center,style:const TextStyle(color:muted,height:1.6)))));}

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});
  @override State<AppSettingsPage> createState() => _AppSettingsPageState();
}
class _AppSettingsPageState extends State<AppSettingsPage> {
  bool biometric = false, compact = false, sounds = true, haptics = true, accessibility = false;
  String language = 'हिन्दी + English';
  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('APP PREFERENCES', style: TextStyle(fontWeight: FontWeight.w900, color: muted, letterSpacing: 1)),
      const SizedBox(height: 8),
      ListTile(leading: const Icon(Icons.language, color: blue), title: const Text('App language'), subtitle: Text(language), trailing: const Icon(Icons.chevron_right), onTap: () async {
        final picked = await showModalBottomSheet<String>(context: c, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: ['हिन्दी + English','हिन्दी','English','ગુજરાતી','ਪੰਜਾਬੀ'].map((v) => ListTile(title: Text(v), trailing: v == language ? const Icon(Icons.check,color:blue) : null, onTap: () => Navigator.pop(ctx,v))).toList())));
        if (picked != null) setState(() => language = picked);
      }),
      SwitchListTile(value: sounds, onChanged: (v)=>setState(()=>sounds=v), secondary: const Icon(Icons.volume_up_outlined), title: const Text('Sound effects')),
      SwitchListTile(value: haptics, onChanged: (v)=>setState(()=>haptics=v), secondary: const Icon(Icons.vibration), title: const Text('Haptic feedback')),
      SwitchListTile(value: compact, onChanged: (v)=>setState(()=>compact=v), secondary: const Icon(Icons.view_agenda_outlined), title: const Text('Compact layout')),
      SwitchListTile(value: accessibility, onChanged: (v)=>setState(()=>accessibility=v), secondary: const Icon(Icons.accessibility_new), title: const Text('Accessibility mode')),
      const Divider(height: 28),
      const Text('PRIVACY & SECURITY', style: TextStyle(fontWeight: FontWeight.w900, color: muted, letterSpacing: 1)),
      SwitchListTile(value: biometric, onChanged: (v)=>setState(()=>biometric=v), secondary: const Icon(Icons.fingerprint), title: const Text('Biometric unlock'), subtitle: const Text('Preference preview; device authentication is not connected.')),
      ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy controls'), subtitle: const Text('Review permissions and data handling'), onTap: ()=>page(c,const PlainPage(title:'Privacy controls'))),
      ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & support'), onTap: ()=>page(c,const PlainPage(title:'Help & support'))),
      const Padding(padding: EdgeInsets.all(8), child: Text('These preferences currently apply only in this open session. Persistent settings will be added with local storage/backend.',style:TextStyle(fontSize:11,color:muted))),
    ]),
  );
}
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override State<NotificationsPage> createState() => _NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> alerts = [
    {'title':'Welcome to Zing Zone','message':'Your app workspace is ready to explore.','time':'Just now','icon':Icons.waving_hand_outlined,'read':false},
    {'title':'Rewards & tokens','message':'Token balance and rewards will appear here when the rewards service is connected.','time':'Today','icon':Icons.card_giftcard_outlined,'read':false},
    {'title':'Public service updates','message':'Application status updates will appear here after service integration.','time':'Today','icon':Icons.assignment_outlined,'read':false},
  ];
  @override Widget build(BuildContext c) {
    final unread = alerts.where((a) => a['read'] == false).length;
    return Scaffold(appBar: AppBar(title: const Text('Notifications'), actions: [
      TextButton(onPressed: () => setState(() { for (final a in alerts) { a['read'] = true; } }), child: const Text('Mark all read')),
    ]), body: Column(children: [
      Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(16,8,16,12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFEDF0FF), borderRadius: BorderRadius.circular(18)), child: Row(children: [
        const Icon(Icons.notifications_active, color: blue, size: 30), const SizedBox(width:12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(unread == 0 ? 'You’re all caught up' : '$unread unread notifications', style: const TextStyle(fontWeight: FontWeight.w900, color: navy)),
          const Text('Your updates, all in one place', style: TextStyle(color: muted, fontSize: 12)),
        ])),
      ])),
      Expanded(child: alerts.isEmpty ? const Center(child: Text('No notifications yet.')) : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal:12), itemCount: alerts.length, separatorBuilder: (_, __) => const Divider(height:1),
        itemBuilder: (ctx, i) {
          final a = alerts[i]; final read = a['read'] as bool;
          return ListTile(onTap: () => setState(() => a['read'] = true),
            leading: CircleAvatar(backgroundColor: read ? pale : const Color(0xFFE9ECFF), child: Icon(a['icon'] as IconData, color: read ? muted : blue)),
            title: Row(children: [Expanded(child: Text(a['title'] as String, style: TextStyle(fontWeight: read ? FontWeight.w600 : FontWeight.w900, color: navy))), if (!read) Container(width:8,height:8,decoration:const BoxDecoration(color:blue,shape:BoxShape.circle))]),
            subtitle: Padding(padding: const EdgeInsets.only(top:4), child: Text('${a['message']}\\n${a['time']}', style: const TextStyle(color:muted,height:1.4))),
          );
        })),
      const Padding(padding: EdgeInsets.all(12), child: Text('These are in-app demo notices. Live messages and push alerts require backend/notification service setup.', textAlign: TextAlign.center, style: TextStyle(fontSize:10,color:muted))),
    ]));
  }
}
class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});
  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Zing Premium')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF111831), Color(0xFF5141A5), Color(0xFF8754C7)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.workspace_premium, color: Color(0xFFFFD98A), size: 42), SizedBox(height:18),
        Text('ZING PREMIUM', style: TextStyle(color:Colors.white,fontSize:26,fontWeight:FontWeight.w900,letterSpacing:1)),
        SizedBox(height:8), Text('A more powerful Zing Zone experience', style: TextStyle(color:Colors.white70)),
        SizedBox(height:24), Text('MEMBERSHIP',style:TextStyle(color:Color(0xFFFFD98A),fontWeight:FontWeight.w900,letterSpacing:1)),
        SizedBox(height:5), Text('Choose a plan when subscriptions are available.',style:TextStyle(color:Colors.white)),
      ])),
      const SizedBox(height:16),
      const _MembershipFeature(icon:Icons.auto_awesome,title:'AI assistant',subtitle:'Premium AI access will activate when the AI service is connected.'),
      const _MembershipFeature(icon:Icons.document_scanner_outlined,title:'Smart document tools',subtitle:'Enhanced document features planned for the connected service.'),
      const _MembershipFeature(icon:Icons.support_agent,title:'Priority support',subtitle:'Premium support will be enabled when support is launched.'),
      const SizedBox(height:16),
      FilledButton.icon(onPressed:()=>note(c,'Premium plans and checkout are not live yet. No payment has been taken.'), icon:const Icon(Icons.lock_outline), style:FilledButton.styleFrom(backgroundColor:violet,minimumSize:const Size.fromHeight(52)), label:const Text('Plans coming soon')),
      const Padding(padding:EdgeInsets.only(top:10),child:Text('No subscription is active and no payment can be made in this preview.',textAlign:TextAlign.center,style:TextStyle(fontSize:11,color:muted))),
    ]),
  );
}
class TokenBalanceBadge extends StatelessWidget {
  final VoidCallback onTap;
  const TokenBalanceBadge({super.key, required this.onTap});
  @override Widget build(BuildContext context) {
    // Widget tests and pre-Firebase preview can render the shell before Firebase initializes.
    if (Firebase.apps.isEmpty) return IconButton(tooltip: 'Tokens — sign in to view balance', onPressed: onTap, icon: const Icon(Icons.token, color: Color(0xFFB27A18)));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return IconButton(tooltip: 'Tokens — sign in to view balance', onPressed: onTap, icon: const Icon(Icons.token, color: Color(0xFFB27A18)));
    final entries = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tokens');
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: entries.snapshots(),
      builder: (context, snapshot) {
        var balance = 0;
        if (snapshot.hasData) { for (final doc in snapshot.data!.docs) { final value = doc.data()['delta']; if (value is num) balance += value.toInt(); } }
        final label = snapshot.hasError ? '!' : (snapshot.hasData ? '$balance' : '…');
        return Padding(padding: const EdgeInsets.only(left: 2, right: 4), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFFFF4DA), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEAD6A5))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.token, size: 18, color: Color(0xFF9B6816)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF80540D)))]))));
      },
    );
  }
}

class TokenPage extends StatelessWidget {
  const TokenPage({super.key});
  @override Widget build(BuildContext c) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(appBar: AppBar(title: const Text('Zing Tokens')), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.token, size: 54, color: Color(0xFFB27A18)), const SizedBox(height: 12), const Text('Sign in to view your token wallet', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: navy)), const SizedBox(height: 8), const Text('Your token balance and transaction history are linked to your account.', textAlign: TextAlign.center, style: TextStyle(color: muted)), const SizedBox(height: 16), FilledButton(onPressed: () => page(c, const Welcome()), child: const Text('Sign in'))]))));
    final entries = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tokens');
    return Scaffold(appBar: AppBar(title: const Text('Zing Tokens')), body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: entries.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        var balance = 0;
        for (final doc in docs) { final delta = doc.data()['delta']; if (delta is num) balance += delta.toInt(); }
        return ListView(padding: const EdgeInsets.all(18), children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF201A10), Color(0xFF76501B), Color(0xFFC18A2D)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.token, color: Color(0xFFFFE3A0), size: 34), SizedBox(width: 10), Text('TOKEN WALLET', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
            const SizedBox(height: 20),
            Text(snapshot.hasError ? '—' : (snapshot.hasData ? '$balance' : '…'), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
            const Text('TOKENS AVAILABLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(snapshot.hasError ? 'Could not load token ledger. Check connection and account permissions.' : (snapshot.hasData ? 'Live account balance • updates automatically when the trusted service records a transaction.' : 'Connecting to your token ledger…'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          const SizedBox(height: 18), const Text('TOKEN ACTIVITY', style: TextStyle(fontWeight: FontWeight.w900, color: muted, letterSpacing: 1)), const SizedBox(height: 8),
          if (snapshot.hasError) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Token history could not be loaded. Please try again later.')))
          else if (!snapshot.hasData) const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())))
          else if (docs.isEmpty) const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(18), child: Column(children: [Icon(Icons.history, size: 36, color: muted), SizedBox(height: 8), Text('No token transactions yet', style: TextStyle(fontWeight: FontWeight.w800, color: navy)), SizedBox(height: 4), Text('When the trusted rewards service adds or uses tokens, each transaction will appear here.', textAlign: TextAlign.center, style: TextStyle(color: muted))])))
          else ...docs.map((doc) {
            final data = doc.data(); final delta = data['delta'] is num ? (data['delta'] as num).toInt() : 0;
            final description = data['description'] is String ? data['description'] as String : 'Token transaction';
            final createdAt = data['createdAt'];
            final time = createdAt is Timestamp ? '${createdAt.toDate().day.toString().padLeft(2, '0')}/${createdAt.toDate().month.toString().padLeft(2, '0')}/${createdAt.toDate().year}' : 'Date unavailable';
            return Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: line)), child: ListTile(leading: CircleAvatar(backgroundColor: delta >= 0 ? const Color(0xFFE6F6EC) : const Color(0xFFFFE9E9), child: Icon(delta >= 0 ? Icons.add : Icons.remove, color: delta >= 0 ? const Color(0xFF23824A) : Colors.red)), title: Text(description, style: const TextStyle(fontWeight: FontWeight.w800, color: navy)), subtitle: Text(time, style: const TextStyle(color: muted, fontSize: 11)), trailing: Text('${delta > 0 ? '+' : ''}$delta', style: TextStyle(fontWeight: FontWeight.w900, color: delta >= 0 ? const Color(0xFF23824A) : Colors.red))));
          }),
          const Padding(padding: EdgeInsets.only(top: 12), child: Text('The app cannot create tokens on the device. Only trusted server-side transactions should change this balance.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: muted))),
        ]);
      },
    ));
  }
}
class _MembershipFeature extends StatelessWidget {
  final IconData icon; final String title,subtitle;
  const _MembershipFeature({required this.icon,required this.title,required this.subtitle});
  @override Widget build(BuildContext c)=>Card(color:Colors.white,elevation:0,child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFEDF0FF),child:Icon(icon,color:blue)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(subtitle,style:const TextStyle(fontSize:11,color:muted))));
}
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Wallet & earning hub')),body:ListView(padding:const EdgeInsets.all(18),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:navy,borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('DEMO WALLET BALANCE',style:TextStyle(color:Colors.white70,fontSize:11)),SizedBox(height:8),Text('₹0.00',style:TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w900)),Text('No real money is stored in this prototype.',style:TextStyle(color:Colors.white70,fontSize:11))])),
    const SizedBox(height:12),
    _ProfileRow(icon:Icons.receipt_long,title:'Transaction history',sub:'Wallet credits and debits',onTap:()=>page(c,const PlainPage(title:'Transaction history'))),
    _ProfileRow(icon:Icons.account_balance,title:'Withdrawal methods',sub:'Bank account and UPI setup',onTap:()=>page(c,const PlainPage(title:'Withdrawal methods'))),
    const SizedBox(height:12),
    FilledButton(onPressed:()=>note(c,'Wallet and withdrawal are disabled until secure backend and payment compliance are configured.'),child:const Text('Withdraw')),
  ]));
}
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('My orders & returns')),body:const Center(child:Padding(padding:EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.local_shipping_outlined,size:56,color:blue),SizedBox(height:12),Text('Orders placed on Meesho/Flipkart/Amazon appear in those apps.',textAlign:TextAlign.center,style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),SizedBox(height:8),Text('Zing Zone does not yet have its own merchant order tracking or returns service.',textAlign:TextAlign.center,style:TextStyle(color:muted))]))));
}
