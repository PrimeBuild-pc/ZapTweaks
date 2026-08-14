import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:script_utility/core/services/power_plan_service.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('discovers the complete bundled power-plan library', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = PowerPlanService(
      preferences: await SharedPreferences.getInstance(),
      processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
    );

    final plans = await service.availablePlans();
    expect(plans, hasLength(91));
    expect(
      plans.map((plan) => plan.name),
      contains('Microsoft Ultimate Performance'),
    );
  });
}
