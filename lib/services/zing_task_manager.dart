import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ZingTaskManager {
  static const _key='zz_ai_tasks_v1';
  static Future<List<Map<String,dynamic>>> loadTasks() async {
    final p=await SharedPreferences.getInstance();final raw=p.getString(_key);if(raw==null)return [];
    try {final list=jsonDecode(raw) as List;return list.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();}catch(_){return [];}
  }
  static Future<void> _save(List<Map<String,dynamic>> tasks) async {
    final p=await SharedPreferences.getInstance();await p.setString(_key,jsonEncode(tasks.take(50).toList()));
  }
  static Future<void> recordUserMessage(String text) async {
    final form=RegExp(r'form|application|bharna|भरना|फॉर्म|आवेदन|भर्ती|recruitment|scholarship|छात्रवृत्ति|certificate|प्रमाणपत्र|योजना|licence|लाइसेंस',caseSensitive:false).hasMatch(text);
    if(!form)return;
    final tasks=await loadTasks();final now=DateTime.now().toIso8601String();
    final existing=tasks.indexWhere((t)=>t['status']!='completed'&&t['status']!='stopped');
    if(existing>=0){tasks[existing]['lastUserMessage']=text.substring(0,text.length>1200?1200:text.length);tasks[existing]['updatedAt']=now;}
    else {final title=text.trim().replaceAll(RegExp(r'\s+'),' ');tasks.insert(0,{'id':'task_${DateTime.now().microsecondsSinceEpoch}','kind':'form_assistance','title':title.substring(0,title.length>90?90:title.length),'status':'in_progress','lastUserMessage':text.substring(0,text.length>1200?1200:text.length),'createdAt':now,'updatedAt':now});}
    await _save(tasks);
  }
  static Future<void> recordAssistantResult(String intent,String? taskId) async {
    if(intent!='form_assistance'&&intent!='document_help')return;
    final tasks=await loadTasks();if(tasks.isEmpty)return;
    final index=tasks.indexWhere((t)=>t['status']!='completed'&&t['status']!='stopped');if(index<0)return;
    tasks[index]['lastAssistantIntent']=intent;tasks[index]['updatedAt']=DateTime.now().toIso8601String();
    if(taskId!=null)tasks[index]['serverTaskId']=taskId;
    await _save(tasks);
  }
  static Future<void> deleteTask(String id) async {final tasks=await loadTasks();tasks.removeWhere((t)=>t['id']==id);await _save(tasks);}
}
