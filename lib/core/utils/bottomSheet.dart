import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/constance/textStyle.dart';
import 'package:deshi/core/data/local/app_database.dart';
import 'package:deshi/core/services/appwrite_service.dart';
import 'package:deshi/core/utils/mini button.dart';
import 'package:deshi/core/utils/orderBUTON.dart';
import 'package:deshi/feature/home/presentation/widgets/progress_step.dart';
import 'package:deshi/feature/account/presentation/screens/account_screen.dart';
import 'package:flutter/material.dart';

enum _OrderAuthChoice { login, register, guest }

class Bottomsheet extends StatefulWidget {
  final String productName;
  final String ProductPrice;
  const Bottomsheet({
    super.key,
    required this.productName,
    required this.ProductPrice,
  });

  @override
  State<Bottomsheet> createState() => _BottomsheetState();
}

class _BottomsheetState extends State<Bottomsheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();

  int _step = 1;
  int _quantity = 1;
  String? _weight;
  String? _deliveryTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLastCustomerDetails();
  }

  Future<void> _loadLastCustomerDetails() async {
    try {
      final profile = await AppwriteService().getCustomerProfile();
      if (!mounted) return;
      if (!profile.isAnonymous) {
        setState(() {
          _nameController.text = profile.name;
          _phoneController.text = profile.phone;
          _addressController.text = profile.address;
        });
        return;
      }
    } on AppwriteException catch (error) {
      debugPrint(
        'Profile prefill unavailable: ${AppwriteService.errorMessage(error)}',
      );
    } on StateError catch (error) {
      debugPrint('Profile prefill unavailable: $error');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      if (_isSubmitting) return;

      final missingFields = <String>[
        if (_weight == null) 'ওজন',
        if (_deliveryTime == null) 'ডেলিভারি সময়',
        if (_nameController.text.trim().isEmpty) 'আপনার নাম',
        if (_phoneController.text.trim().isEmpty) 'মোবাইল নম্বর',
        if (_districtController.text.trim().isEmpty) 'জেলা',
        if (_areaController.text.trim().isEmpty) 'এলাকা',
        if (_addressController.text.trim().isEmpty) 'সম্পূর্ণ ঠিকানা',
      ];
      if (missingFields.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('অনুগ্রহ করে পূরণ করুন: ${missingFields.join(', ')}'),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      final authenticated = await _ensureOrderSession();
      if (!authenticated) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
      final address = [
        _districtController.text.trim(),
        _areaController.text.trim(),
        _addressController.text.trim(),
      ].join(', ');

      try {
        await appDatabase.insertOrder(
          productName: widget.productName,
          customerName: _nameController.text.trim(),
          weight: _weight!,
          price: productminPrice() + 60,
          quantity: _quantity,
          address: address,
          phone: _phoneController.text.trim(),
          status: 'pending',
          deliveryTimeline: _deliveryTime,
        );
      } on Exception catch (error) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'অর্ডার সংরক্ষণ করা যায়নি: '
              '${AppwriteService.errorMessage(error)}',
            ),
          ),
        );
        return;
      }

      if (mounted) {
        _nameController.clear();
        _phoneController.clear();
        _districtController.clear();
        _areaController.clear();
        _addressController.clear();
        Navigator.of(context).pop(true);
      }

      // Local storage is complete, so cloud sync must not delay confirmation.
      unawaited(
        AppwriteService().syncPendingOrders(
          onError: (message) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ক্লাউডে অর্ডার পাঠানো যায়নি: $message')),
            );
          },
        ),
      );
    }
  }

  Future<bool> _ensureOrderSession() async {
      final existing = await AppwriteService().ensureUser();
      if (existing != null) return true;
      if (!mounted) return false;

      final choice = await showDialog<_OrderAuthChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('অর্ডার নিশ্চিত করতে লগইন করুন'),
          content: const Text(
            'আপনার অর্ডার সঠিক অ্যাকাউন্টের সঙ্গে যুক্ত রাখতে একটি অপশন বেছে নিন।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _OrderAuthChoice.login),
              child: const Text('লগইন'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _OrderAuthChoice.register),
              child: const Text('অ্যাকাউন্ট তৈরি করুন'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _OrderAuthChoice.guest),
              child: const Text('অতিথি হিসেবে অর্ডার'),
            ),
          ],
        ),
      );
      if (!mounted || choice == null) return false;

      if (choice == _OrderAuthChoice.guest) {
        try {
          await AppwriteService().createGuestSession();
          return true;
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'অতিথি সেশন তৈরি করা যায়নি: '
                  '${AppwriteService.errorMessage(error)}',
                ),
              ),
            );
          }
          return false;
        }
      }

      await Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const AccountScreen()));
    return await AppwriteService().ensureUser() != null;
  }

  void _previous() {
    if (_step > 1) {
      setState(() => _step--);
    }
  }

  double? get minWeight {
    switch (_weight) {
      case '800g–1kg':
        return 0.8;
      case '1–1.5kg':
        return 1.0;
      case '1.5–2kg':
        return 1.5;
      default:
        return null;
    }
  }

  double? get maxWeight {
    switch (_weight) {
      case '800g–1kg':
        return 1.0;
      case '1–1.5kg':
        return 1.5;
      case '1.5–2kg':
        return 2.0;
      default:
        return null;
    }
  }

  double productminPrice() {
    final pricePerKg = double.parse(widget.ProductPrice);
    if (minWeight == null || maxWeight == null) {
      return 0;
    }
    final minPrice = _quantity * minWeight! * pricePerKg;
    return minPrice;
  }

  double productmaxPrice() {
    final pricePerKg = double.parse(widget.ProductPrice);
    if (minWeight == null || maxWeight == null) {
      return 0;
    }
    final maxPrice = _quantity * maxWeight! * pricePerKg;
    return maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    return Container(
      height: _step < 2 ? deviceSize.height * .6 : deviceSize.height * .8,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: ColorConst.darkGreenColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'দেশি ${widget.productName} অর্ডার করুন',
                      style: TextConst.heading.copyWith(
                        color: ColorConst.darkGreenColor,
                      ),
                    ),
                    Text(
                      '৳ ${widget.ProductPrice} / কেজি',
                      style: TextConst.body.copyWith(
                        color: ColorConst.lightGreen,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: ColorConst.lightGreen),
              ),
            ],
          ),
          Divider(color: ColorConst.lightGreen.withAlpha(50), thickness: 0.5),
          ProgressStep(completedSteps: List.generate(_step - 1, (i) => i + 1)),
          Divider(color: ColorConst.lightGreen.withAlpha(50), thickness: 0.5),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10),
              child: _stepContent(),
            ),
          ),
          _navigationButtons(),
        ],
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 1:
        return _quantityStep();
      case 2:
        return _weightStep();
      case 3:
        return _deliveryTimeStep();
      case 4:
        return _deliveryDetailsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _quantityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('কতটি প্রয়োজন?'),
        _panel(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              miniButton(
                isBorderEnable: true,
                icon: Icons.remove,
                color: Colors.white,
                iconColor: ColorConst.darkGreenColor,
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Text(
                      '$_quantity',
                      style: TextConst.heading.copyWith(
                        color: ColorConst.darkGreenColor,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'পিস',
                      style: TextConst.subheading.copyWith(
                        color: ColorConst.lightGreen,
                      ),
                    ),
                  ],
                ),
              ),
              miniButton(
                isBorderEnable: false,
                icon: Icons.add,
                color: ColorConst.darkGreenColor,
                iconColor: Colors.white,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weightStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('প্রতি পিস আনুমানিক ওজন'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['800g–1kg', '1–1.5kg', '1.5–2kg', 'নির্দিষ্ট নয়']
              .map(
                (weight) => _choiceButton(
                  label: weight,
                  selected: _weight == weight,
                  onTap: () => setState(() => _weight = weight),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 15),
        _summary(),
      ],
    );
  }

  Widget _deliveryTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('কখন প্রয়োজন?'),
        ...[
          '⚡ যত দ্রুত সম্ভব',
          '▣ 1–2 দিন',
          '▣ 3–5 দিন',
          '□ নির্দিষ্ট তারিখ',
        ].map(
          (time) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _choiceButton(
              label: time,
              selected: _deliveryTime == time,
              fullWidth: true,
              onTap: () => setState(() => _deliveryTime = time),
            ),
          ),
        ),
        _summary(),
      ],
    );
  }

  Widget _deliveryDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ডেলিভারির তথ্য'),
        _field('আপনার নাম *', 'পূর্ণ নাম', _nameController),
        _field('মোবাইল নম্বর *', '01XXXXXXXXX', _phoneController),
        _field('জেলা *', 'যেমন: ঢাকা', _districtController),
        _field('এলাকা *', 'থানা / উপজেলা', _areaController),
        _field(
          'সম্পূর্ণ ঠিকানা *',
          'বাড়ি নং, রোড, মহল্লা',
          _addressController,
        ),
        _summary(),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Text(
      title,
      style: TextConst.subheading.copyWith(color: ColorConst.darkGreenColor),
    ),
  );

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: ColorConst.lightGreen.withAlpha(30),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _choiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : 145,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? ColorConst.lightGreen.withAlpha(60) : Colors.white,
          border: Border.all(
            color: selected
                ? ColorConst.darkGreenColor
                : ColorConst.lightGreen.withAlpha(100),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: fullWidth ? TextAlign.start : TextAlign.center,
          style: TextConst.body.copyWith(color: ColorConst.darkGreenColor),
        ),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextConst.body.copyWith(color: ColorConst.darkGreenColor),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorConst.lightGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    const deliveryCharge = 60.0;
    final totalPrice = minWeight == null
        ? 'ওজন নির্বাচন করুন'
        : '৳${(productminPrice() + deliveryCharge).toStringAsFixed(0)}–৳${(productmaxPrice() + deliveryCharge).toStringAsFixed(0)}';

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 আনুমানিক মূল্য',
            style: TextConst.body.copyWith(color: ColorConst.darkGreenColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('পরিমাণ'), Text('$_quantity pcs')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('আনুমানিক ওজন'),
              Text(_weight ?? 'নির্বাচন করুন'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('পণ্যর দাম'),
              Text(
                minWeight == null
                    ? 'ওজন নির্বাচন করুন'
                    : '৳${productminPrice().toStringAsFixed(0)}–৳${productmaxPrice().toStringAsFixed(0)}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('ডেলিভারি'), Text('৳60')],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'মোট (আনুমানিক)',
                style: TextConst.body.copyWith(
                  color: ColorConst.darkGreenColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalPrice,
                style: TextConst.body.copyWith(
                  color: ColorConst.darkGreenColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navigationButtons() => Row(
    children: [
      if (_step > 1)
        Expanded(
          child: OrderButton(
            onTap: _previous,
            title: 'পেছনে',
            color: Colors.redAccent.withAlpha(80),
          ),
        ),
      if (_step > 1) const SizedBox(width: 10),
      Expanded(
        child: OrderButton(
          title: _isSubmitting
              ? 'সংরক্ষণ হচ্ছে...'
              : _step == 4
              ? 'কনফার্ম করুন'
              : 'পরবর্তী',
          onTap: _isSubmitting ? () {} : _next,
        ),
      ),
    ],
  );
}
