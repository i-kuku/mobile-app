class FinancialSummaryModel {
  final String? batchId;
  final String? batchName;
  final double totalSales;
  final double totalExpenses;
  final double profit;

  final double eggsSales;
  final double chickenSales;
  final double manureSales;

  final Map<String, double> incomeBreakdownPercent;
  final Map<String, double> expenseBreakdownPercent;

  final Map<String, double> incomeBreakdownAmounts;
  final Map<String, double> expenseBreakdownAmounts;

  final double? predictedRevenue;
  final double storeInventoryValue;
  final double mortalityRate;
  final double fcr;

  FinancialSummaryModel({
    this.batchId,
    this.batchName,
    required this.totalSales,
    required this.totalExpenses,
    required this.profit,
    required this.eggsSales,
    required this.chickenSales,
    required this.manureSales,
    required this.incomeBreakdownPercent,
    required this.expenseBreakdownPercent,
    required this.incomeBreakdownAmounts,
    required this.expenseBreakdownAmounts,
    this.predictedRevenue,
    required this.storeInventoryValue,
    required this.mortalityRate,
    required this.fcr,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      batchId: json['batch_id'] as String?,
      batchName: json['batch_name'] as String?,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      eggsSales: (json['eggs_sales'] ?? 0).toDouble(),
      chickenSales: (json['chicken_sales'] ?? 0).toDouble(),
      manureSales: (json['manure_sales'] ?? 0).toDouble(),
      incomeBreakdownPercent: {
        'eggs': (json['eggs_sales_pct'] ?? 0).toDouble(),
        'chicken': (json['chicken_sales_pct'] ?? 0).toDouble(),
        'manure': (json['manure_sales_pct'] ?? 0).toDouble(),
      },
      expenseBreakdownPercent: {
        'feeds': (json['feeds_expense_pct'] ?? 0).toDouble(),
        'vaccines': (json['vaccines_expense_pct'] ?? 0).toDouble(),
        'others': (json['other_expense_pct'] ?? 0).toDouble(),
      },
      incomeBreakdownAmounts: {
        'eggs': (json['eggs_sales'] ?? 0).toDouble(),
        'chicken': (json['chicken_sales'] ?? 0).toDouble(),
        'manure': (json['manure_sales'] ?? 0).toDouble(),
      },
      expenseBreakdownAmounts: {
        'feeds': (json['feed_expense'] ?? 0).toDouble(),
        'vaccines': (json['vaccine_expense'] ?? 0).toDouble(),
        'others': (json['other_expense'] ?? 0).toDouble(),
      },
      predictedRevenue: json['predicted_revenue'] != null
          ? (json['predicted_revenue']).toDouble()
          : null,
      storeInventoryValue: (json['store_inventory_value'] ?? 0).toDouble(),
      mortalityRate: (json['mortality_rate'] ?? 0).toDouble(),
      fcr: (json['fcr'] ?? 0).toDouble(),
    );
  }
  double get totalIncome => totalSales;
  double? get totalRevenue => totalSales;
}