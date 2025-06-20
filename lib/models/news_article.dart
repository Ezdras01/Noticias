// Clase que representa una noticia individual obtenida desde la API
class NewsArticle {
  final String title;         // Título de la noticia
  final String description;   // Descripción corta
  final String url;           // Enlace a la noticia completa
  final String urlToImage;    // URL de la imagen destacada
  final String publishedAt;   // Fecha de publicación
  final String sourceName;    // Nombre del medio o fuente

  // Constructor con todos los campos obligatorios
  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
  });

  // Método fábrica que convierte un JSON en una instancia de NewsArticle
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',                       // Si no hay título, usar cadena vacía
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source']['name'] ?? '',         // "source" es un objeto dentro del JSON
    );
  }
}
