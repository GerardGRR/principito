class Service {
  final int? serviceId;
  final String name;
  final String description;
  final double price;
  final String? link; // Nuevo campo para el enlace del trámite
  final String? imagePath;
  final int isActive;

  Service({
    this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    this.link,
    this.imagePath,
    this.isActive = 1,
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
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['serviceId'],
      name: map['name'],
      description: map['description'] ?? '',
      price: map['price'] ?? 0.0,
      link: map['link'],
      imagePath: map['imagePath'],
      isActive: map['isActive'] ?? 1,
    );
  }
}
