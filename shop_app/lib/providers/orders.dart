import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://flutter-shop-app-5edb7.firebaseio.com/orders.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach(
        (orderId, orderData) {
          loadedOrders.add(
            OrderItem(
                id: orderId,
                amount: orderData['amount'],
                dateTime: DateTime.parse(orderData['dateTime']),
                products: (orderData['products'] as List<dynamic>)
                    .map(
                      (item) => CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['title'],
                      ),
                    )
                    .toList()),
          );
        },
      );
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://flutter-shop-app-5edb7.firebaseio.com/orders.json';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'dateTime': DateTime.now().toIso8601String(),
            'products': cartProducts
                .map(
                  (cartProduct) => {
                    'id': cartProduct.id,
                    'title': cartProduct.title,
                    'quantity': cartProduct.quantity,
                    'price': cartProduct.price,
                  },
                )
                .toList(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: DateTime.now(),
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
