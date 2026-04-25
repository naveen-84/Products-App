import 'package:dio/dio.dart';
import '../models/product.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Product>> fetchProducts(int page) async {
    final response = await _dio.get(
      'https://dummyjson.com/products',
      queryParameters: {"limit": 10, "skip": page * 10},
    );

    final List data = response.data['products'];
    return data.map((e) => Product.fromJson(e)).toList();
  }
}
