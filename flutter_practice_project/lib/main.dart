import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: '어느날 갑자기 용사가 되어 마왕을 무찌르는 이야기',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  WordPair setCurrent(WordPair newPair) {
    return current = newPair;
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// ...
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final class Tuple<T1, T2> {
  Tuple(this.left, this.right);
  late T1 left;
  late T2 right;
}

abstract interface class StateChanger<T> {
  bool changeWidgetState(T newData);
}

class _MyHomePageState extends State<MyHomePage>
    implements StateChanger<Tuple<int, WordPair>> {
  var selectedIndex = 0;
  WordPair? defaultPair;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(defaultPair: defaultPair);
        break;
      case 1:
        page = FavoritePage(this);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  bool changeWidgetState(Tuple<int, WordPair> newData) {
    if (newData.left >= 0 || newData.left <= 1) {
      setState(() {
        selectedIndex = newData.left;
        defaultPair = newData.right;
      });

      return true;
    }

    return false;
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage(this.stateChanger, {super.key});
  final StateChanger<Tuple<int, WordPair>> stateChanger;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ' '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite),
            title: ElevatedButton(
                onPressed: () {
                  stateChanger.changeWidgetState(Tuple<int, WordPair>(0, pair));
                },
                child: Text(pair.asLowerCase)),
          ),
      ],
    );
  }
}

class MyFavoritePage extends StatelessWidget {
  const MyFavoritePage(this.stateChanger, {super.key});
  final StateChanger<Tuple<int, WordPair>> stateChanger;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Widget> favoritePairs = [];
    for (var pair in appState.favorites) {
      favoritePairs.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // for change the widget to GeneratorPage from FavoritePage
              stateChanger.changeWidgetState(Tuple<int, WordPair>(0, pair));
            },
            child: Text(
              pair.asLowerCase,
              semanticsLabel: "${pair.first} ${pair.second}",
            ),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: favoritePairs,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  GeneratorPage({super.key, this.defaultPair});

  WordPair? defaultPair;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    late WordPair pair;
    if (defaultPair != null) {
      pair = appState.setCurrent(defaultPair as WordPair);
      defaultPair = null;
    } else {
      pair = appState.current;
    }

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
