class FinancialSummary {
  final int totalIncome;
  final int totalExpenses;
  final int? predictedRevenue; // shown when actual revenue < 0
  final int? totalRevenue;     // shown when actual revenue >= 0
  final Map<String, double> incomeBreakdownPercent;  // e.g. {'chicken': 100.0}
  final Map<String, double> expenseBreakdownPercent; // e.g. {'feeds': 40.0, 'vaccines': 40.0, 'birds': 20.0}
  final int storeInventoryValue;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.predictedRevenue,
    required this.totalRevenue,
    required this.incomeBreakdownPercent,
    required this.expenseBreakdownPercent,
    required this.storeInventoryValue,
  });

  static FinancialSummary compute({
    required int totalIncome,
    required int feedsExpense,
    required int vaccinesExpense,
    required int othersExpense,
    required int birdsExpense,
    required int startingChickens,
    required int chickensDied,
    required int storeInventoryValue,
  }) {
    final totalExpenses = feedsExpense + vaccinesExpense + othersExpense + birdsExpense;
    final actualRevenue = totalIncome - totalExpenses;
    final remainingChickens = startingChickens - chickensDied;

    int? predictedRevenue;
    int? totalRevenue;

    if (actualRevenue < 0) {
      predictedRevenue = (remainingChickens * 600) - totalExpenses;
    } else {
      totalRevenue = actualRevenue;
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      predictedRevenue: predictedRevenue,
      totalRevenue: totalRevenue,
      incomeBreakdownPercent: _computeIncomeBreakdown(totalIncome),
      expenseBreakdownPercent: _computeExpenseBreakdown(
        feeds: feedsExpense,
        vaccines: vaccinesExpense,
        others: othersExpense,
        birds: birdsExpense,
        totalExpenses: totalExpenses,
      ),
      storeInventoryValue: storeInventoryValue,
    );
  }

  static Map<String, double> _computeIncomeBreakdown(int totalIncome) {
    // Eggs and manure are static placeholders for now — only chicken is real.
    if (totalIncome <= 0) {
      return {'chicken': 0, 'eggs': 0, 'manure': 0};
    }
    return {
      'chicken': 100.0, // 100% since eggs/manure aren't calculated yet
      'eggs': 0,
      'manure': 0,
    };
  }

  static Map<String, double> _computeExpenseBreakdown({
    required int feeds,
    required int vaccines,
    required int others,
    required int birds,
    required int totalExpenses,
  }) {
    if (totalExpenses <= 0) {
      return {'feeds': 0, 'vaccines': 0, 'others': 0, 'birds': 0};
    }
    return {
      'feeds': (feeds / totalExpenses) * 100,
      'vaccines': (vaccines / totalExpenses) * 100,
      'others': (others / totalExpenses) * 100,
      'birds': (birds / totalExpenses) * 100,
    };
  }
}