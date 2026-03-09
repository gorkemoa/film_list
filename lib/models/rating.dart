class Rating {
  final String source;
  final String value;

  Rating({required this.source, required this.value});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      source: json['Source'] ?? json['source'] ?? '',
      value: json['Value'] ?? json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'source': source, 'value': value};
  }
}
