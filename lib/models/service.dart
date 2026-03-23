class Service {
  final int? serviceId;
  final String name;
  final String description;
  final double price;

  Service({
    this.serviceId,
    required this.name,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['serviceId'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
    );
  }
}
