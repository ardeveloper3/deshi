import 'package:appwrite/models.dart' as models;
import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/data/models/customer_profile.dart';
import 'package:deshi/core/services/appwrite_service.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _service = AppwriteService();
  late Future<_AccountData> _dataFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _dataFuture = _loadAccount();
  }

  Future<_AccountData> _loadAccount() async {
    final user = await _service.ensureUser();
    if (user == null) {
      return const _AccountData(
        profile: CustomerProfile(
          userId: '',
          name: '',
          phone: '',
          address: '',
          email: '',
          isAnonymous: true,
        ),
        orders: [],
      );
    }
    final values = await Future.wait([
      _service.getCustomerProfile(),
      _service.getCurrentUserOrders(),
    ]);
    return _AccountData(
      profile: values[0] as CustomerProfile,
      orders: values[1] as List<models.Row>,
    );
  }

  Future<void> _login() async {
    final email = TextEditingController();
    final password = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('লগইন'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'ইমেইল'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'সঠিক ইমেইল লিখুন',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'পাসওয়ার্ড লিখুন',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('লগইন'),
          ),
        ],
      ),
    );
    final emailValue = email.text;
    final passwordValue = password.text;
    email.dispose();
    password.dispose();
    if (confirmed != true || !mounted) return;
    try {
      await _service.login(email: emailValue, password: passwordValue);
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('লগইন সফল হয়েছে')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'লগইন করা যায়নি: ${AppwriteService.errorMessage(error)}',
          ),
        ),
      );
    }
  }

  String _value(models.Row row, String key) =>
      row.data[key]?.toString().trim() ?? '';

  int _orderProgress(List<models.Row> orders) {
    final unique = <String, models.Row>{for (final row in orders) row.$id: row};
    return unique.length.clamp(0, 20);
  }

  Future<void> _editProfile(CustomerProfile profile) async {
    final name = TextEditingController(text: profile.name);
    final phone = TextEditingController(text: profile.phone);
    final address = TextEditingController(text: profile.address);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('প্রোফাইল সম্পাদনা'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'নাম'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'নাম লিখুন'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'ফোন নম্বর'),
                  validator: (value) => value == null || value.trim().length < 7
                      ? 'সঠিক ফোন নম্বর লিখুন'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: address,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'ঠিকানা'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'ঠিকানা লিখুন'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
    final savedName = name.text;
    final savedPhone = phone.text;
    final savedAddress = address.text;
    name.dispose();
    phone.dispose();
    address.dispose();
    if (result != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await _service.saveCustomerProfile(
        name: savedName,
        phone: savedPhone,
        address: savedAddress,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _reload();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('প্রোফাইল সংরক্ষণ হয়েছে')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'সংরক্ষণ করা যায়নি: ${AppwriteService.errorMessage(error)}',
          ),
        ),
      );
    }
  }

  Future<void> _register() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('অ্যাকাউন্ট তৈরি করুন'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'রেজিস্ট্রেশন ঐচ্ছিক। এতে আপনার অর্ডারগুলো একই অ্যাকাউন্টে থাকবে।',
              ),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'নাম'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'নাম লিখুন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'ইমেইল'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'সঠিক ইমেইল লিখুন',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'পাসওয়ার্ড (কমপক্ষে ৮ অক্ষর)',
                ),
                validator: (value) => value != null && value.length >= 8
                    ? null
                    : 'কমপক্ষে ৮ অক্ষর লিখুন',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('এখন নয়'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('রেজিস্টার'),
          ),
        ],
      ),
    );
    if (result != true || !mounted) return;
    try {
      await _service.registerAccount(
        name: name.text,
        email: email.text,
        password: password.text,
      );
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'রেজিস্ট্রেশন করা যায়নি: ${AppwriteService.errorMessage(error)}',
          ),
        ),
      );
    } finally {
      email.dispose();
      password.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমার অ্যাকাউন্ট')),
      body: FutureBuilder<_AccountData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _RetryState(
              message: AppwriteService.errorMessage(snapshot.error!),
              onRetry: () => setState(_reload),
            );
          }
          final data = snapshot.data!;
          if (data.profile.userId.isEmpty) {
            return _AuthLanding(onLogin: _login, onCreateAccount: _register);
          }
          final completed = _orderProgress(data.orders);
          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileCard(
                          profile: data.profile,
                          saving: _saving,
                          onEdit: () => _editProfile(data.profile),
                          onRegister: data.profile.isAnonymous
                              ? _register
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _OverviewCard(orders: data.orders),
                        const SizedBox(height: 16),
                        _ProgressCard(completed: completed),
                        const SizedBox(height: 24),
                        Text(
                          'অর্ডার হিস্ট্রি',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: ColorConst.darkGreenColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 10),
                        if (data.orders.isEmpty)
                          const _EmptyOrders()
                        else
                          ...data.orders.map(
                            (row) => _OrderCard(row: row, value: _value),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.orders});

  final List<models.Row> orders;

  String _value(models.Row row, String key) =>
      row.data[key]?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final active = orders
        .where((row) => _value(row, 'status').toLowerCase() != 'completed')
        .length;
    final completed = orders.length - active;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ওভারভিউ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ColorConst.darkGreenColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _OverviewValue(label: 'মোট অর্ডার', value: '${orders.length}'),
                _OverviewValue(label: 'চলমান', value: '$active'),
                _OverviewValue(label: 'সম্পন্ন', value: '$completed'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewValue extends StatelessWidget {
  const _OverviewValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: ColorConst.darkGreenColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: TextStyle(color: ColorConst.muted)),
        ],
      ),
    );
  }
}

class _AccountData {
  const _AccountData({required this.profile, required this.orders});
  final CustomerProfile profile;
  final List<models.Row> orders;
}

class _AuthLanding extends StatelessWidget {
  const _AuthLanding({required this.onLogin, required this.onCreateAccount});

  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 58),
                  const SizedBox(height: 12),
                  Text(
                    'আমার অ্যাকাউন্ট',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'অর্ডার দেখতে বা সংরক্ষণ করতে লগইন করুন। '
                    'অর্ডারের সময় চাইলে অতিথি হিসেবেও এগোনো যাবে।',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onLogin,
                      child: const Text('লগইন'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onCreateAccount,
                      child: const Text('অ্যাকাউন্ট তৈরি করুন'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'অতিথি অ্যাকাউন্ট শুধু অর্ডার নিশ্চিত করার সময় তৈরি হবে।',
                        ),
                      ),
                    ),
                    child: const Text('অতিথি হিসেবে চালিয়ে যান'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.saving,
    required this.onEdit,
    required this.onRegister,
  });
  final CustomerProfile profile;
  final bool saving;
  final VoidCallback onEdit;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final name = profile.name.isEmpty ? 'অতিথি ক্রেতা' : profile.name;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ColorConst.lightGreen,
                  child: Text(
                    profile.name.isEmpty
                        ? '?'
                        : profile.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: ColorConst.darkGreenColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        profile.phone.isEmpty
                            ? 'ফোন নম্বর যোগ করুন'
                            : profile.phone,
                      ),
                      Text(
                        profile.address.isEmpty
                            ? 'ঠিকানা যোগ করুন'
                            : profile.address,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'প্রোফাইল সম্পাদনা',
                  onPressed: saving ? null : onEdit,
                  icon: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            if (onRegister != null) ...[
              const Divider(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'রেজিস্ট্রেশন ঐচ্ছিক। অ্যাকাউন্ট তৈরি করলে আপনার অর্ডার ও তথ্য নিরাপদে থাকবে।',
                  style: TextStyle(color: ColorConst.muted),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRegister,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('অ্যাকাউন্ট তৈরি করুন'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.completed});
  final int completed;

  @override
  Widget build(BuildContext context) {
    final complete = completed >= 20;
    return Card(
      color: const Color(0xFFEAF8EF),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'আপনার অর্ডার যাত্রা',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: ColorConst.darkGreenColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$completed / 20 অর্ডার',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                20,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < completed
                        ? ColorConst.darkGreenColor
                        : ColorConst.lightGreen.withAlpha(100),
                  ),
                  child: index < completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              complete
                  ? 'অভিনন্দন! আপনি একটি ফ্রি উপহার পেয়েছেন!'
                  : 'আরও ${20 - completed}টি অর্ডার হলে ফ্রি উপহার পাবেন।',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: complete ? ColorConst.darkGreenColor : ColorConst.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.row, required this.value});
  final models.Row row;
  final String Function(models.Row, String) value;

  @override
  Widget build(BuildContext context) {
    final status = value(row, 'status');
    final price = value(row, 'price');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    value(row, 'productName'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(label: Text(status.isEmpty ? 'অজানা' : status)),
              ],
            ),
            const SizedBox(height: 8),
            Text('অর্ডার: ${row.$id}'),
            Text(
              'ওজন: ${value(row, 'weight')}  •  পরিমাণ: ${value(row, 'quantity')}',
            ),
            Text('মোট: ৳$price'),
            Text('ঠিকানা: ${value(row, 'address')}'),
            if (value(row, 'phone').isNotEmpty)
              Text('ফোন: ${value(row, 'phone')}'),
            if (row.$createdAt.isNotEmpty)
              Text('তারিখ: ${_formatDate(row.$createdAt)}'),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: ColorConst.lightGreen,
          ),
          const SizedBox(height: 8),
          const Text('এখনও কোনো অর্ডার নেই'),
          Text(
            'আপনার করা অর্ডারগুলো এখানে দেখা যাবে',
            style: TextStyle(color: ColorConst.muted),
          ),
        ],
      ),
    ),
  );
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 52),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('আবার চেষ্টা করুন'),
          ),
        ],
      ),
    ),
  );
}
