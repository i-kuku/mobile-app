import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/financial summaries/model/financial_summary_model.dart';

void main() {
  group('FinancialSummaryModel', () {
    
    test('converts database data into financialsummary correctly', () {
      final mockJson = <String, dynamic>{
        'batch_id': 'b12345-6789-0000',
        'batch_name': 'Batch Alpha',
        'total_sales': 150000.00,
        'total_expenses': 45000.50,
        'profit': 104999.50,
        'eggs_sales': 0.00,
        'chicken_sales': 150000.00,
        'manure_sales': 0.00,
        'eggs_sales_pct': 0.00,
        'chicken_sales_pct': 100.00,
        'manure_sales_pct': 0.00,
        'feeds_expense_pct': 60.00,
        'vaccines_expense_pct': 25.00,
        'other_expense_pct': 15.00,
        'feed_expense': 27000.30,
        'vaccine_expense': 11250.12,
        'other_expense': 6750.08,
        'predicted_revenue': 230000.00,
        'store_inventory_value': 12000.00,
        'mortality_rate': 2.50,
        'fcr': 1.65,
      };

      final model = FinancialSummaryModel.fromJson(mockJson);

      expect(model.batchId, equals('b12345-6789-0000'));
      expect(model.batchName, equals('Batch Alpha'));
      expect(model.totalSales, equals(150000.00));
      expect(model.totalExpenses, equals(45000.50));
      expect(model.profit, equals(104999.50));

      // Test maps
      expect(model.incomeBreakdownPercent['chicken'], equals(100.00));
      expect(model.expenseBreakdownPercent['feeds'], equals(60.00));
      expect(model.expenseBreakdownAmounts['vaccines'], equals(11250.12));

      // Test metrics
      expect(model.predictedRevenue, equals(230000.00));
      expect(model.mortalityRate, equals(2.50));
      expect(model.fcr, equals(1.65));
    });

    test('fromJson handles nulls and integer types safely without throwing errors', () {
      final mockJsonWithIntegersAndNulls = <String, dynamic>{
        'batch_id': null,
        'batch_name': null,
        'total_sales': 100, // int instead of double
        'total_expenses': 0,
        'profit': 100,
        'predicted_revenue': null,
        'store_inventory_value': 0,
        'mortality_rate': 0,
        'fcr': 0,
      };

      final model = FinancialSummaryModel.fromJson(mockJsonWithIntegersAndNulls);

      expect(model.batchId, isNull);
      expect(model.batchName, isNull);
      expect(model.predictedRevenue, isNull);
      expect(model.totalSales, equals(100.0)); // Converted from int to double
      expect(model.expenseBreakdownPercent['feeds'], equals(0.0)); // Default fallback
    });

    test('Computed getters return expected revenue and income values', () {
      final model = FinancialSummaryModel(
        totalSales: 80000.0,
        totalExpenses: 20000.0,
        profit: 60000.0,
        eggsSales: 0.0,
        chickenSales: 80000.0,
        manureSales: 0.0,
        incomeBreakdownPercent: {},
        expenseBreakdownPercent: {},
        incomeBreakdownAmounts: {},
        expenseBreakdownAmounts: {},
        storeInventoryValue: 5000.0,
        mortalityRate: 1.2,
        fcr: 1.4,
      );

      expect(model.totalIncome, equals(80000.0));
      expect(model.totalRevenue, equals(80000.0));
    });
  });
}