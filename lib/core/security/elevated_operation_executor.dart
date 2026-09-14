import '../operations/operation.dart';
import '../plans/plan_engine.dart';
import 'elevated_helper.dart';

class ElevatedOperationExecutor implements OperationExecutor {
  const ElevatedOperationExecutor(this.client);

  final ElevatedHelperClient client;

  @override
  Future<void> apply(
    OperationDefinition definition,
    OperationRequest request,
  ) => client.applyNativeOperation(request);

  @override
  Future<void> rollback(
    OperationDefinition definition,
    OperationRequest request,
    OperationSnapshot snapshot,
  ) => client.rollbackNativeOperation(request, snapshot);
}
