import 'package:flutter/widgets.dart';

import 'app_controller.dart';

class ClinicAppScope extends InheritedNotifier<ClinicAppController> {
  const ClinicAppScope({
    super.key,
    required ClinicAppController controller,
    required super.child,
  }) : super(notifier: controller);

  static ClinicAppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ClinicAppScope>();
    assert(scope != null, 'ClinicAppScope is missing in widget tree.');
    return scope!.notifier!;
  }
}
