import 'package:core_paywall/core_paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final subPlan = const PaywallPlan(
    id: 'pro_annual',
    billingType: PlanBillingType.autoRenewable,
    title: 'Annual Pro',
    localizedPrice: '\$29.99/yr',
    trialDays: 3,
    badgeText: 'SAVE 50%',
  );

  final lifetimePlan = const PaywallPlan(
    id: 'pro_lifetime',
    billingType: PlanBillingType.lifetime,
    title: 'Lifetime',
    localizedPrice: '\$69.99',
    specificPerks: ['Lifetime updates'],
  );

  final consumablePlan = const PaywallPlan(
    id: 'credits_500',
    billingType: PlanBillingType.consumable,
    title: '500 Credits',
    localizedPrice: '\$4.99',
  );

  group('PaywallTemplate & Controller Tests', () {
    test('PaywallTemplate.fromString parses case-insensitively and falls back', () {
      expect(PaywallTemplate.fromString('timeline'), PaywallTemplate.timeline);
      expect(
        PaywallTemplate.fromString('SinglePurchase'),
        PaywallTemplate.singlePurchase,
      );
      expect(PaywallTemplate.fromString('unknown'), PaywallTemplate.classic);
    });

    test('Controller updates CTA, disclaimer and restore visibility per SKU', () {
      final ctrl = PaywallController(
        placement: 'home',
        template: PaywallTemplate.classic,
        plans: [subPlan, lifetimePlan, consumablePlan],
        strings: PaywallStrings.en(),
        onPurchase: (_) async => const PaywallPurchaseResult.success(),
        onRestore: () async => const PaywallPurchaseResult.success(),
      );

      expect(ctrl.selectedPlan?.id, 'pro_annual');
      expect(ctrl.resolvedCtaText, 'Start 3-Day Free Trial');
      expect(ctrl.resolvedLegalDisclaimer, contains('Free for 3 days'));
      expect(ctrl.shouldShowRestore, isTrue);

      ctrl.selectPlan(lifetimePlan);
      expect(ctrl.resolvedCtaText, 'Unlock Forever · \$69.99');
      expect(ctrl.resolvedLegalDisclaimer, contains('Permanent access'));
      expect(ctrl.shouldShowRestore, isTrue);

      ctrl.selectPlan(consumablePlan);
      expect(ctrl.resolvedCtaText, 'Buy Now · \$4.99');
      expect(ctrl.resolvedLegalDisclaimer, contains('consumable purchase'));
      expect(ctrl.shouldShowRestore, isFalse);
    });

    test('onBeforePurchase hook can cancel purchase flow cleanly', () async {
      bool purchaseCalled = false;
      final ctrl = PaywallController(
        placement: 'export',
        template: PaywallTemplate.classic,
        plans: [subPlan],
        strings: PaywallStrings.en(),
        onBeforePurchase: (_) async => false,
        onPurchase: (_) async {
          purchaseCalled = true;
          return const PaywallPurchaseResult.success();
        },
      );

      final res = await ctrl.purchase();
      expect(res, isNull);
      expect(purchaseCalled, isFalse);
      expect(ctrl.isBusy, isFalse);
    });
  });

  group('Paywall Widget & Flow Tests', () {
    testWidgets('Classic fullscreen paywall handles retention and purchase', (tester) async {
      final events = <PaywallEventType>[];
      PaywallResult? finalResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  finalResult = await Paywall.show(
                    context,
                    placement: 'onboarding',
                    plans: [subPlan, lifetimePlan],
                    links: PaywallLinks(
                      termsUrl: 'https://example.com/terms',
                      privacyUrl: 'https://example.com/privacy',
                      onOpenUrl: (_) {},
                    ),
                    retentionConfig: RetentionConfig(
                      title: 'Wait!',
                      subtitle: 'Try our discounted plan.',
                      offerPlan: lifetimePlan,
                      dismissButtonText: 'Leave',
                    ),
                    onEvent: (e) => events.add(e.type),
                    onPurchase: (plan) async => const PaywallPurchaseResult.success(),
                    onRestore: () async => const PaywallPurchaseResult.success(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock Pro Access'), findsOneWidget);
      expect(find.text('Start 3-Day Free Trial'), findsOneWidget);
      expect(events, contains(PaywallEventType.paywallShown));

      // Tap close -> triggers retention dialog once
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Wait!'), findsOneWidget);

      // Dismiss retention dialog -> closes paywall
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(finalResult?.isDismissed, isTrue);
      expect(events, contains(PaywallEventType.retentionShown));
      expect(events, contains(PaywallEventType.paywallDismissed));
    });

    testWidgets('SinglePurchase bottom sheet supports custom contentBuilder', (tester) async {
      PaywallResult? finalResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  finalResult = await Paywall.show(
                    context,
                    placement: '4k_export',
                    template: PaywallTemplate.singlePurchase,
                    plans: [
                      const PaywallPlan(
                        id: 'export_4k',
                        billingType: PlanBillingType.consumable,
                        title: '4K Export',
                        localizedPrice: '\$1.99',
                        description: 'Single high-res export',
                      ),
                    ],
                    links: PaywallLinks(
                      onOpenTerms: () {},
                      onOpenPrivacy: () {},
                    ),
                    contentBuilder: (_) => const Text('Custom Preview Banner'),
                    onPurchase: (_) async => const PaywallPurchaseResult.success(),
                  );
                },
                child: const Text('Unlock'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(find.text('4K Export'), findsOneWidget);
      expect(find.text('Custom Preview Banner'), findsOneWidget);
      expect(find.text('Restore'), findsNothing);

      await tester.tap(find.text('Buy Now · \$1.99'));
      await tester.pumpAndSettle();

      expect(finalResult?.isPurchased, isTrue);
      expect(finalResult?.plan?.id, 'export_4k');
    });
  });
}
