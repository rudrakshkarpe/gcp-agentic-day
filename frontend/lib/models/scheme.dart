class Scheme {
  final String id;
  final String name;
  final String description;
  final String eligibility;
  final String benefits;
  final String category;
  final bool isActive;

  Scheme({
    required this.id,
    required this.name,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.category,
    required this.isActive,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      benefits: json['benefits'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'eligibility': eligibility,
      'benefits': benefits,
      'category': category,
      'isActive': isActive,
    };
  }
}
