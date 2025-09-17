// // // lib/models/transaction_model.dart
// // class TransactionModel {
// //   String category;
// //   String account;
// //   double amount;
// //   String? note;
// //   DateTime date;
// //   String type;
// //
// //   TransactionModel({
// //     required this.category,
// //     required this.account,
// //     required this.amount,
// //     this.note,
// //     required this.date,
// //     required this.type,
// //   });
// // }
// //
// //
// class TransactionModel {
//   final int? id;
//   double amount;
//   String type;
//   String category;
//   String? note;
//   final DateTime createdAt;
//   final int userId;
//   DateTime date;
//   String account;
//
//   TransactionModel({
//     this.id,
//     required this.amount,
//     required this.type,
//     required this.category,
//     this.note,
//     required this.createdAt,
//     required this.userId,
//     required this.date,
//     required this.account,
//   });
//
//   static List<TransactionModel> transactions = [];
//
//   factory TransactionModel.fromJson(Map<String, dynamic> json) {
//     return TransactionModel(
//       id: json['id'],
//       amount: (json['amount'] as num).toDouble(),
//       type: json['type'],
//       category: json['category'],
//       account: json['account'],
//       note: json['note'],
//       createdAt: DateTime.parse(json['createdAt']),
//       userId: json['userId'],
//       date: DateTime.parse(json['date']), // ✅ FIX
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "amount": amount,
//       "type": type,
//       "category": category,
//       "note": note,
//       "createdAt": createdAt.toIso8601String(),
//       "userId": userId,
//       "date": date.toIso8601String(), // ✅ FIX
//       "account": account,
//     };
//   }
// }
