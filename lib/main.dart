import 'package:flutter/material.dart';

void main() {
  runApp(const ZingZoneApp());
}

class ZingZoneApp extends StatelessWidget {
  const ZingZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zing Zone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315CFF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF151827),
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const ZingHome(),
    );
  }
}

class ZingHome extends StatefulWidget {
  const ZingHome({super.key});

  @override
  State<ZingHome> createState() => _ZingHomeState();
}

class _ZingHomeState extends State<ZingHome> {
  int _tab = 0;
  final TextEditingController _chatController = TextEditingController();
  final List<String> _messages = [];

  static const Color ink = Color(0xFF171A2B);
  static const Color blue = Color(0xFF315CFF);
  static const Color muted = Color(0xFF73798D);
  static const Color pale = Color(0xFFF4F6FF);

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(message);
      _chatController.clear();
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo mode: AI service abhi connect nahi hai.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _chatPage(),
      _storePage(),
      _rewardsPage(),
      _profilePage(),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Profile',
          onPressed: () => setState(() => _tab = 3),
          icon: const CircleAvatar(
            radius: 17,
            backgroundColor: pale,
            child: Icon(Icons.person_outline_rounded, color: ink, size: 21),
          ),
        ),
        title: const Text(
          'ZING ZONE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tokens',
            onPressed: () => _notice('Token Center abhi demo mode mein hai.'),
            icon: const Icon(Icons.token_outlined, color: blue),
          ),
          IconButton(
            tooltip: 'Premium',
            onPressed: () => _notice('Premium Center abhi demo mode mein hai.'),
            icon: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFB8860B)),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _notice('Abhi koi nayi notification nahi hai.'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE9EEFF),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Store'),
          NavigationDestination(icon: Icon(Icons.stars_outlined), selectedIcon: Icon(Icons.stars_rounded), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  void _notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _chatPage() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF315CFF), Color(0xFF7048E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: blue.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                    SizedBox(height: 18),
                    Text('Aapka kaam,\\naasaan tareeke se.',
                      style: TextStyle(color: Colors.white, fontSize: 27, height: 1.15, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10),
                    Text('Sarkari forms, documents aur digital services ke liye shuru karein.',
                      style: TextStyle(color: Color(0xFFE9ECFF), fontSize: 14, height: 1.45)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Aaj kya karna hai?', style: TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _quickAction(Icons.assignment_outlined, 'Form bharna', 'Mujhe form bharne mein madad chahiye'),
                  _quickAction(Icons.description_outlined, 'Document', 'Mujhe document taiyar karna hai'),
                  _quickAction(Icons.search_rounded, 'Service khojein', 'Mere liye sahi sarkari service khojo'),
                  _quickAction(Icons.track_changes_rounded, 'Status check', 'Meri application ka status check karna hai'),
                ],
              ),
              if (_messages.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Is chat mein', style: TextStyle(color: ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ..._messages.map((message) => Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(color: const Color(0xFFE9EEFF), borderRadius: BorderRadius.circular(17)),
                    child: Text(message, style: const TextStyle(color: ink)),
                  ),
                )),
              ],
              const SizedBox(height: 18),
              const Text('Aapki privacy important hai. OTP, password ya payment ko hamesha khud verify karein.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Attach document',
                onPressed: () => _notice('Document picker next integration step mein add hoga.'),
                icon: const Icon(Icons.attach_file_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(hintText: 'Apna kaam yahan likhein…', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Send',
                onPressed: _sendMessage,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, String prompt) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: blue),
      label: Text(label),
      onPressed: () {
        setState(() => _chatController.text = prompt);
        FocusScope.of(context).requestFocus(FocusNode());
      },
      backgroundColor: pale,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
    );
  }

  Widget _storePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Store', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 6),
        const Text('Products, offers aur useful services ek jagah.', style: TextStyle(color: muted)),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: 'Product ya service search karein',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(onPressed: () => _notice('Voice search baad mein connect hoga.'), icon: const Icon(Icons.mic_none_rounded)),
          ),
          onSubmitted: (value) => _notice('Search service abhi connect nahi hai: $value'),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Explore categories'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _category(Icons.phone_android_rounded, 'Electronics'),
            _category(Icons.school_outlined, 'Study & Books'),
            _category(Icons.home_outlined, 'Home essentials'),
            _category(Icons.miscellaneous_services_outlined, 'Useful services'),
          ],
        ),
        const SizedBox(height: 18),
        _emptyCard(Icons.local_offer_outlined, 'Offers yahan dikhenge', 'Verified deals connect hone ke baad show honge.'),
      ],
    );
  }

  Widget _rewardsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Rewards', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 6),
        const Text('Tasks complete karein aur apne points track karein.', style: TextStyle(color: muted)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: const Color(0xFFF1EEFF), borderRadius: BorderRadius.circular(24)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.stars_rounded, size: 30, color: Color(0xFF7048E8)),
              SizedBox(height: 14),
              Text('0 points', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
              SizedBox(height: 4),
              Text('Demo balance · abhi koi real reward credit nahi hua', style: TextStyle(color: muted, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('Discover rewards'),
        const SizedBox(height: 12),
        _featureRow(Icons.calendar_today_outlined, 'Daily check-in', 'Roz aakar apni progress dekhein', () => _notice('Check-in backend abhi connect nahi hai.')),
        _featureRow(Icons.quiz_outlined, 'Quick quiz', 'Knowledge-based activities', () => _notice('Quiz feature abhi demo mode mein hai.')),
        _featureRow(Icons.flag_outlined, 'Missions', 'Available tasks aur challenges', () => _notice('Missions abhi load nahi ho rahe.')),
        _featureRow(Icons.history_rounded, 'Points history', 'Apne reward records dekhein', () => _notice('Abhi koi reward transaction nahi hai.')),
      ],
    );
  }

  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(22)),
          child: const Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person_outline_rounded, size: 30, color: blue)),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome to Zing Zone', style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 4),
                Text('Profile setup baad mein karein', style: TextStyle(color: muted, fontSize: 12)),
              ])),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Your account'),
        const SizedBox(height: 8),
        _featureRow(Icons.assignment_outlined, 'My Applications', 'Saved aur submitted applications', () => _notice('Application locker backend abhi connect nahi hai.')),
        _featureRow(Icons.folder_open_outlined, 'Document Vault', 'Documents ko manage karein', () => _notice('Secure document storage abhi setup nahi hai.')),
        _featureRow(Icons.account_balance_wallet_outlined, 'Wallet & Earnings', 'Balance aur transaction history', () => _notice('Wallet abhi connect nahi hai.')),
        _featureRow(Icons.token_outlined, 'Token Center', 'Token balance aur usage', () => _notice('Token Center abhi demo mode mein hai.')),
        _featureRow(Icons.workspace_premium_outlined, 'Premium Center', 'Plans aur membership', () => _notice('Premium purchase abhi enabled nahi hai.')),
        _featureRow(Icons.notifications_none_rounded, 'Notifications', 'Updates aur alerts', () => _notice('Abhi koi nayi notification nahi hai.')),
        _featureRow(Icons.settings_outlined, 'Settings', 'Language, appearance aur privacy', () => _settingsSheet()),
        _featureRow(Icons.help_outline_rounded, 'Help & Support', 'FAQs aur support requests', () => _notice('Support system abhi connect nahi hai.')),
        _featureRow(Icons.info_outline_rounded, 'About Zing Zone', 'App information', () => showAboutDialog(context: context, applicationName: 'Zing Zone', applicationVersion: '1.0.0', children: const [Text('Citizen-service app interface preview. Online services are not connected yet.')])),
      ],
    );
  }

  void _settingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              ListTile(leading: const Icon(Icons.language_rounded), title: const Text('Language'), subtitle: const Text('Hindi / English — coming next'), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.text_fields_rounded), title: const Text('Text size & readability'), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.dark_mode_outlined), title: const Text('Appearance'), subtitle: const Text('Light mode enabled'), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy & security'), onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800));

  Widget _category(IconData icon, String title) {
    return InkWell(
      onTap: () => _notice('$title: product catalogue abhi connect nahi hai.'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: blue, size: 25),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _emptyCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8EAF2)), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Icon(icon, color: blue, size: 27),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: blue),
      ),
      title: Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: muted),
      onTap: onTap,
    );
  }
}
