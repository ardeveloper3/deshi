import 'package:flutter_riverpod/legacy.dart';

final stepsProvider = StateProvider<List<int>>((ref) {
  return [0];
});
