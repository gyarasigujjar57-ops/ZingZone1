import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZingWorkspaceStore {
  static const supportedLanguages = <String>[
    'हिन्दी + English','हिन्दी','English','অসমীয়া','বাংলা','ગુજરાતી','ಕನ್ನಡ','कोंकणी','मैथिली','മലയാളം','মণিপুরী','मराठी','नेपाली','ଓଡ଼ିଆ','ਪੰਜਾਬੀ','संस्कृत','سنڌي','தமிழ்','తెలుగు','اردو','डोगरी','बोडो','काश्मीरी','संताली'
  ];
  static Future<String> loadLanguage() async {
    final p=await SharedPreferences.getInstance();
    return p.getString('zz_language_v2') ?? 'हिन्दी + English';
  }
  static Future<void> saveLanguage(String language) async {
    final p=await SharedPreferences.getInstance();
    await p.setString('zz_language_v2',language);
    try {
      final user=FirebaseAuth.instance.currentUser;
      if(user!=null) await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'language':language,'updatedAt':FieldValue.serverTimestamp()},SetOptions(merge:true));
    } catch (_) {}
  }
  static Future<Map<String,String>> loadProfile() async {
    final p=await SharedPreferences.getInstance();
    Map<String,String> local={};
    final raw=p.getString('zz_master_profile_v1');
    if(raw!=null){try{final d=jsonDecode(raw);if(d is Map){local={for(final e in d.entries)e.key.toString():e.value.toString()};}}catch(_){}}
    try {
      final user=FirebaseAuth.instance.currentUser;
      if(user!=null){
        final snap=await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if(snap.exists){final data=snap.data()??{};for(final k in const ['displayName','state','district']){final v=data[k];if(v is String&&v.isNotEmpty)local[k]=v;}}
      }
    } catch (_) {}
    return local;
  }
  static Future<void> saveProfile(Map<String,String> profile) async {
    final safe=<String,String>{};
    for(final k in const ['displayName','state','district']){final v=profile[k]?.trim()??'';if(v.isNotEmpty)safe[k]=v.substring(0,v.length>100?100:v.length);}
    final p=await SharedPreferences.getInstance();
    await p.setString('zz_master_profile_v1',jsonEncode(safe));
    try {
      final user=FirebaseAuth.instance.currentUser;
      if(user!=null) await FirebaseFirestore.instance.collection('users').doc(user.uid).set({...safe,'updatedAt':FieldValue.serverTimestamp()},SetOptions(merge:true));
    } catch (_) {}
  }
  static Future<void> saveCurrentChat(String value) async {
    try {final user=FirebaseAuth.instance.currentUser;if(user!=null)await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('chats').doc('current').set({'content':value,'updatedAt':FieldValue.serverTimestamp()});} catch (_) {}
  }
  static Future<String?> loadCurrentChat() async {
    try {final user=FirebaseAuth.instance.currentUser;if(user==null)return null;final snap=await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('chats').doc('current').get();final value=snap.data()?['content'];if(value is String)return value;} catch (_) {}
    return null;
  }
  static Future<void> archiveChat(String value) async {
    try {final user=FirebaseAuth.instance.currentUser;if(user!=null&&value.trim().isNotEmpty)await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('chats').add({'content':value,'createdAt':FieldValue.serverTimestamp()});} catch (_) {}
  }
}
