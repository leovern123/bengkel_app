import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';

class DataService {
  // === PRODUCTS ===
  static Future<List<ProductModel>> getProducts() async {
    try {
      final response = await ApiClient.dio.get("/products");
      return (response.data as List).map((i) => ProductModel.fromJson(i)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addProduct(ProductModel product, {dynamic imageFile}) async {
    try {
      Map<String, dynamic> data = product.toJson();
      
      if (imageFile != null) {
        // Gunakan FormData untuk upload file
        FormData formData = FormData.fromMap({
          ...data,
          'gambar': await _createMultipartFile(imageFile),
        });
        
        await ApiClient.dio.post("/products", data: formData);
      } else {
        await ApiClient.dio.post("/products", data: data);
      }
      return true;
    } catch (e) {
      if (e is DioException) {
        print("Error adding product: ${e.response?.data ?? e.message}");
      } else {
        print("Error adding product: $e");
      }
      return false;
    }
  }

  static Future<bool> updateProduct(int id, ProductModel product, {dynamic imageFile}) async {
    try {
      Map<String, dynamic> data = product.toJson();
      
      if (imageFile != null) {
        // Laravel PUT with Multipart requires _method override
        FormData formData = FormData.fromMap({
          ...data,
          '_method': 'PUT',
          'gambar': await _createMultipartFile(imageFile),
        });
        
        await ApiClient.dio.post("/products/$id", data: formData);
      } else {
        await ApiClient.dio.put("/products/$id", data: data);
      }
      return true;
    } catch (e) {
      if (e is DioException) {
        print("Error updating product: ${e.response?.data ?? e.message}");
      } else {
        print("Error updating product: $e");
      }
      return false;
    }
  }

  static Future<MultipartFile> _createMultipartFile(dynamic file) async {
    String path = (file is String) ? file : file.path;
    String fileName = path.split('/').last;
    
    return await MultipartFile.fromFile(
      path,
      filename: fileName,
    );
  }

  static Future<bool> deleteProduct(int id) async {
    try {
      await ApiClient.dio.delete("/products/$id");
      return true;
    } catch (e) {
      return false;
    }
  }

  // === SERVICES ===
  static Future<List<ServiceModel>> getServices() async {
    try {
      final response = await ApiClient.dio.get("/services");
      return (response.data as List).map((i) => ServiceModel.fromJson(i)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addService(ServiceModel service) async {
    try {
      await ApiClient.dio.post("/services", data: service.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateService(int id, ServiceModel service) async {
    try {
      await ApiClient.dio.put("/services/$id", data: service.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteService(int id) async {
    try {
      await ApiClient.dio.delete("/services/$id");
      return true;
    } catch (e) {
      return false;
    }
  }

  // === CUSTOMERS ===
  static Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await ApiClient.dio.get("/customers");
      return (response.data as List).map((i) => CustomerModel.fromJson(i)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addCustomer(CustomerModel customer) async {
    try {
      await ApiClient.dio.post("/customers", data: customer.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCustomer(int id, CustomerModel customer) async {
    try {
      await ApiClient.dio.put("/customers/$id", data: customer.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCustomer(int id) async {
    try {
      await ApiClient.dio.delete("/customers/$id");
      return true;
    } catch (e) {
      return false;
    }
  }

  // === ORDERS ===
  static Future<bool> addOrder(Map<String, dynamic> orderData) async {
    try {
      await ApiClient.dio.post("/orders", data: orderData);
      return true;
    } catch (e) {
      print("Error adding order: $e");
      return false;
    }
  }

  static Future<List<OrderModel>> getOrders() async {
    try {
      final response = await ApiClient.dio.get("/orders");
      return (response.data as List).map((i) => OrderModel.fromJson(i)).toList();
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }
}
