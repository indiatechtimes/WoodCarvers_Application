import '../providers/api_provider.dart';

class SalesPoint {
  final String date;
  final double revenue;
  final int orders;
  SalesPoint({required this.date, required this.revenue, required this.orders});

  factory SalesPoint.fromJson(Map<String, dynamic> json) => SalesPoint(
        date: json['date'] ?? '',
        revenue: (json['revenue'] ?? 0).toDouble(),
        orders: json['orders'] ?? 0,
      );
}

class DashboardStats {
  final double revenue;
  final int ordersCount;
  final int productsCount;
  final int customersCount;
  final List<Map<String, dynamic>> lowStock;
  final List<Map<String, dynamic>> recentOrders;
  final List<SalesPoint> salesSeries;
  final List<Map<String, dynamic>> topProducts;

  DashboardStats({
    required this.revenue,
    required this.ordersCount,
    required this.productsCount,
    required this.customersCount,
    required this.lowStock,
    required this.recentOrders,
    required this.salesSeries,
    required this.topProducts,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return DashboardStats(
      revenue: (stats['revenue'] ?? 0).toDouble(),
      ordersCount: stats['ordersCount'] ?? 0,
      productsCount: stats['productsCount'] ?? 0,
      customersCount: stats['customersCount'] ?? 0,
      lowStock: (json['lowStock'] as List? ?? []).cast<Map<String, dynamic>>(),
      recentOrders: (json['recentOrders'] as List? ?? []).cast<Map<String, dynamic>>(),
      salesSeries: (json['salesSeries'] as List? ?? []).map((s) => SalesPoint.fromJson(s)).toList(),
      topProducts: (json['topProducts'] as List? ?? []).cast<Map<String, dynamic>>(),
    );
  }
}

class AnalyticsRepository {
  final _api = ApiProvider().dio;

  Future<DashboardStats> getDashboardStats() async {
    final res = await _api.get('/admin/analytics');
    return DashboardStats.fromJson(res.data);
  }
}
