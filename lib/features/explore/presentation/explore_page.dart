import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<_Section> sections = [
    _Section(
      title: "File-based routing",
      content:
      "Este app tem duas telas: home_page.dart e explore_page.dart. O layout principal (main_app.dart) define o BottomNavigationBar que navega entre elas.",
    ),
    _Section(
      title: "Android, iOS e Web",
      content:
      "Você pode rodar este projeto em Android, iOS e Web. Para abrir a versão web, execute 'flutter run -d chrome' no terminal.",
    ),
    _Section(
      title: "Imagens",
      content:
      "Para imagens estáticas, use o diretório 'assets/images'. Você pode adicionar versões @2x e @3x para diferentes densidades de tela.",
    ),
    _Section(
      title: "Tema claro e escuro",
      content:
      "O Flutter suporta tema claro e escuro nativamente. Use o ThemeData.light() e ThemeData.dark() no MaterialApp.",
    ),
    _Section(
      title: "Animações",
      content:
      "O Flutter tem uma API poderosa de animações, como AnimatedContainer e AnimatedBuilder, para criar efeitos suaves.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final section = sections[i];
          return _CollapsibleTile(section: section);
        },
      ),
    );
  }
}

class _CollapsibleTile extends StatefulWidget {
  final _Section section;
  const _CollapsibleTile({required this.section});

  @override
  State<_CollapsibleTile> createState() => _CollapsibleTileState();
}

class _CollapsibleTileState extends State<_CollapsibleTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          widget.section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => setState(() => expanded = value),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.section.content),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});
}
