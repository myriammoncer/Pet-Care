import 'package:dio/dio.dart';

import '../domain/cart.dart';
import '../domain/order.dart';
import '../domain/product.dart';

/// Appels réseau du module Marketplace.
class MarketplaceApi {
  MarketplaceApi(this._dio);
  final Dio _dio;

  /// Récupère la liste des produits.
  Future<List<Product>> list() async {
    final response = await _dio.get('/products');
    final content = response.data['data']['content'] as List<dynamic>;
    return content.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Récupère un produit par son identifiant.
  Future<Product> getById(String id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Crée un nouveau produit dans la boutique (POST /products).
  Future<void> createProduct(Map<String, dynamic> productData) async {
    await _dio.post('/products', data: productData);
  }

  /// Récupère le panier d'achat de l'utilisateur.
  Future<Cart> getCart() async {
    final response = await _dio.get('/cart');
    final data = response.data['data'] ?? response.data;
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  /// Ajoute un produit au panier.
  Future<Cart> addToCart(String productId, int quantity) async {
    final response = await _dio.post('/cart/items', data: {
      'productId': productId,
      'quantity': quantity,
    });
    final data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return Cart.fromJson(data);
    }
    return getCart();
  }

  /// Met à jour la quantité d'un article du panier.
  Future<Cart> updateCartItem(String itemId, int quantity) async {
    final response = await _dio.put('/cart/items/$itemId', data: {
      'quantity': quantity,
    });
    final data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return Cart.fromJson(data);
    }
    return getCart();
  }

  /// Supprime un article du panier.
  Future<Cart> removeFromCart(String itemId) async {
    final response = await _dio.delete('/cart/items/$itemId');
    final data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return Cart.fromJson(data);
    }
    return getCart();
  }

  /// Vide l'ensemble du panier.
  Future<void> clearCart() async {
    await _dio.delete('/cart');
  }

  /// Valide la commande (POST /orders).
  Future<Order> createOrder(Map<String, dynamic> body) async {
    final response = await _dio.post('/orders', data: body);
    final data = response.data['data'] ?? response.data;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  /// Récupère l'historique des commandes de l'utilisateur (GET /orders).
  Future<List<Order>> getOrders() async {
    final response = await _dio.get('/orders');
    final rawData = response.data['data'];
    final List<dynamic> content = rawData is Map<String, dynamic>
        ? (rawData['content'] as List<dynamic>? ?? [])
        : (rawData as List<dynamic>? ?? []);
    return content.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }
}
