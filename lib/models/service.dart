class Service {
  final String? serviceId;
  final String name;
  final String description;
  final double price;
  final String? link;
  final String? imagePath;
  final int isActive;
  final int quantity; // Added for sales tracking

  Service({
    this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    this.link,
    this.imagePath,
    this.isActive = 1,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'link': link,
      'imagePath': imagePath,
      'isActive': isActive,
      'quantity': quantity,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map, [String? id]) {
    return Service(
      serviceId: id ?? map['serviceId'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      link: map['link'],
      imagePath: map['imagePath'],
      isActive: map['isActive'] ?? 1,
      quantity: map['quantity'] ?? 1,
    );
  }

  Service copyWith({
    String? serviceId,
    String? name,
    String? description,
    double? price,
    String? link,
    String? imagePath,
    int? isActive,
    int? quantity,
  }) {
    return Service(
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      link: link ?? this.link,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      quantity: quantity ?? this.quantity,
    );
  }
}
