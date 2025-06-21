import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';
import '../widgets/responsive_scaffold.dart';
import '../controllers/theme_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<String> _searchHistory = [];
  String _selectedCountry = 'us';

final Map<String, Map<String, String>> _countryOptions = {
  'us': {'label': '🇺🇸 USA', 'language': 'en'},
  'gb': {'label': '🇬🇧 Reino Unido', 'language': 'en'},
  'fr': {'label': '🇫🇷 Francia', 'language': 'fr'},
  'de': {'label': '🇩🇪 Alemania', 'language': 'de'},
  'it': {'label': '🇮🇹 Italia', 'language': 'it'},
  'es': {'label': '🇪🇸 España', 'language': 'es'},
};


//Widget para seleccionar el país
Widget _buildCountrySelector() {
  return DropdownButton<String>(
    value: _selectedCountry,
    items: _countryOptions.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(entry.value['label']!),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        setState(() => _selectedCountry = value);
        _loadNews(); // recargar titulares con el país seleccionado
      }
    },
  );
}



@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadNews(); // Cargar noticias después del primer frame
  });
}

Future<void> _loadNews({String? query}) async {
  setState(() => _isLoading = true);

  try {
    final articles = query == null || query.isEmpty
        // 🟢 Titulares por país
        ? await _newsService.fetchTopHeadlines(country: _selectedCountry)
        // 🔵 Búsqueda por palabra clave e idioma del país seleccionado
        : await _newsService.searchNews(
            query,
            _countryOptions[_selectedCountry]!['language']!,
          );

    setState(() {
      _articles = articles;
      _isLoading = false;
    });

    if (query != null && query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() => _searchHistory.insert(0, query));
    }
  } catch (e) {
    print('Error al cargar noticias: $e');
    setState(() => _isLoading = false);
  }
}


@override
Widget build(BuildContext context) {
  return ResponsiveScaffold(
appBar: AppBar(
  title: const Text('Noticias Hoy'),
  centerTitle: true,
  actions: [
    IconButton(
      tooltip: 'Cambiar tema',
      icon: Icon(
        Theme.of(context).brightness == Brightness.dark
            ? Icons.wb_sunny      // ☀️ en modo oscuro, muestra sol
            : Icons.nightlight_round, // 🌙 en modo claro, muestra luna
      ),
      onPressed: () {
        // Cambia el tema usando el Provider
        Provider.of<ThemeController>(context, listen: false).toggleTheme();
      },
    ),
  ],
),
    mobile: _buildMobileContent(),
    tablet: _buildTabletContent(),
  );
}

Widget _buildMobileContent() {
  return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 🔍 Barra de búsqueda
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar noticias...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadNews(); // Volver a cargar titulares
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (value) => _loadNews(query: value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _loadNews(query: _searchController.text),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
                    const SizedBox(height: 12),
                    _buildCountrySelector(),
                    const SizedBox(height: 12),

              // 📚 Historial
              if (_searchHistory.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Historial:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => setState(() => _searchHistory.clear()),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Borrar todo'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _searchHistory.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final term = _searchHistory[index];
                          return InputChip(
                            label: Text(term),
                            onPressed: () {
                              _searchController.text = term;
                              _loadNews(query: term);
                            },
                            onDeleted: () => setState(() => _searchHistory.removeAt(index)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              // 📰 Lista de noticias
              Expanded(
                child: ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) => NewsCard(
                    article: _articles[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(article: _articles[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
}


  Widget _buildTabletContent() {
    return Row(
      children: [
        // Lista de noticias (2/3 de pantalla)
        Expanded(
          flex: 2,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) => NewsCard(
                    article: _articles[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(article: _articles[index]),
                      ),
                    ),
                  ),
                ),
        ),
        // Barra de búsqueda (1/3 de pantalla)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
children: [
  // 🌍 Selector de país
  const Text(
    'Selecciona un país:',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 8),
  _buildCountrySelector(),
  const SizedBox(height: 24),

  // 🔍 Barra de búsqueda
  TextField(
    controller: _searchController,
    decoration: const InputDecoration(
      hintText: 'Buscar noticias...',
      border: OutlineInputBorder(),
    ),
    onSubmitted: (value) => _loadNews(query: value),
  ),
  const SizedBox(height: 16),

  // 📚 Historial de búsqueda
if (_searchHistory.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Historial:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _searchHistory.clear()),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar todo'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: _searchHistory.map((term) => InputChip(
          label: Text(term),
          onPressed: () => _loadNews(query: term),
          onDeleted: () => setState(() => _searchHistory.remove(term)),
        )).toList(),
      ),
    ],
  ),

],

            ),
          ),
        ),
      ],
    );
  }
}