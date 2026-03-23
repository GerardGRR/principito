import 'sale.dart';

class SaleHistory {
  final int? historyId;
  final List<Sale> sales;
  final int userId;
  final String date;

  SaleHistory({
    this.historyId,
    required this.sales,
    required this.userId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'userId': userId,
      'date': date,
    };
  }

  factory SaleHistory.fromMap(Map<String, dynamic> map, {List<Sale> sales = const []}) {
    return SaleHistory(
      historyId: map['historyId'],
      sales: sales,
      userId: map['userId'],
      date: map['date'],
    );
  }
}
