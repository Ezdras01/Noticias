import 'dart:convert';                       // Para decodificar respuestas JSON
import 'package:http/http.dart' as http;    // Cliente HTTP para hacer peticiones
import '../models/news_article.dart';       // Modelo de datos de las noticias

// Servicio que se encarga de obtener noticias desde NewsAPI
class NewsService {
  final String apiKey = '90edfa15e4814ba6a66fc2c50a8bf8d7';  // 🔑 Reemplaza con tu clave real
  final String baseUrl = 'https://newsapi.org/v2/top-headlines'; // Endpoint base de la API

  // Método que obtiene los titulares principales (por país)
  Future<List<NewsArticle>> fetchTopHeadlines({String country = 'us'}) async {
    // Construir URL completa con país y clave
    final response = await http.get(Uri.parse('$baseUrl?country=$country&apiKey=$apiKey'));

    // Si la respuesta es exitosa (código 200)
    if (response.statusCode == 200) {
      final data = json.decode(response.body);      // Decodifica el cuerpo JSON
      List articles = data['articles'];             // Extrae la lista de artículos

      // Convierte cada JSON en una instancia de NewsArticle
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      // Si algo falla, lanza una excepción
      throw Exception('Error al cargar noticias');
    }
  }
// Método que obtiene el idioma basado en el código del país
  // Método auxiliar para obtener idioma según país seleccionado
String _getLanguageForCountry(String countryCode) {
  switch (countryCode) {
    case 'us':
    case 'gb':
    case 'in':
      return 'en';
    case 'fr':
      return 'fr';
    case 'de':
      return 'de';
    case 'it':
      return 'it';
    case 'es':
      return 'es';
    default:
      return 'en'; // por defecto, inglés
  }
}

  // Método que obtiene noticias de por palabras clave
Future<List<NewsArticle>> searchNews(String query, String countryCode) async {
 // final url =
   //   'https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&language=en&apiKey=$apiKey';
      
      // Usa el idioma del país seleccionado (solo para mejorar el resultado)
final language = _getLanguageForCountry(countryCode);

final url =
    'https://newsapi.org/v2/everything?q=$query&language=$language&sortBy=publishedAt&apiKey=$apiKey';

    
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List articles = data['articles'];
    return articles.map((json) => NewsArticle.fromJson(json)).toList();
  } else {
    throw Exception('Error al buscar noticias');
  }
}

}

