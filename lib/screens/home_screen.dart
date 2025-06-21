import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';
import '../widgets/responsive_scaffold.dart';

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
          ? await _newsService.fetchTopHeadlines(country: _selectedCountry)
          : await _newsService.searchNews(query, _selectedCountry);

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
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar noticias...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) => _loadNews(query: value),
                ),
                const SizedBox(height: 16),
                if (_searchHistory.isNotEmpty)
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
          ),
        ),
      ],
    );
  }
}