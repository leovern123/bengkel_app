import 'api_client.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../models/customer_model.dart';

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

  static Future<bool> addProduct(ProductModel product) async {
    try {
      await ApiClient.dio.post("/products", data: product.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProduct(int id, ProductModel product) async {
    try {
      await ApiClient.dio.put("/products/$id", data: product.toJson());
      return true;
    } catch (e) {
      return false;
    }
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
}
