import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/main.dart';
import 'package:ecommerce_app_huma_volve/features/home/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/cubit/home_state.dart';

void main() {
  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('HomeCubit initial state has initial status', () {
    final cubit = HomeCubit();
    expect(cubit.state.status, HomeStatus.initial);
    expect(cubit.state.products, isEmpty);
    expect(cubit.state.categories, isEmpty);
    expect(cubit.state.selectedCategoryId, isNull);
    cubit.close();
  });
}
