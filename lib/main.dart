import 'package:flutter/material.dart';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCOM 2025 Voting',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.red),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/nominate': (context) => const NominatePage(),
        '/vote': (context) => const VotePage(),
      },
    );
  }
}

/* ---------------- HOME PAGE ---------------- */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MUBAS SCOM EC 2026',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/nominate'),
                child: const Text('Nominate'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/vote'),
                child: const Text('Vote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- NOMINATE PAGE ---------------- */
class NominatePage extends StatelessWidget {
  const NominatePage({super.key});

  final List<String> positions = const [
    'Chairperson',
    'Secretary',
    'Treasurer',
    'Prayer Director',
    'Publicity Director',
    'Fundraising Director',
    'Welfare Director',
    'Activities Director',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nominate Candidates')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: positions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    positions[index],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter nominee name',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          // TODO: Save nominations
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nominations submitted')),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

/* ---------------- VOTE PAGE ---------------- */
class VotePage extends StatelessWidget {
  const VotePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample structured data
    final candidates = [
      {'position': 'Chairperson', 'name': 'Alice Banda'},
      {'position': 'Secretary', 'name': 'John Phiri'},
      {'position': 'Treasurer', 'name': 'Mary Chirwa'},
      {'position': 'Prayer Director', 'name': 'Peter Zulu'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Vote')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                candidates[index]['position']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              subtitle: Text(candidates[index]['name']!),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Record vote
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You voted for ${candidates[index]['name']}'),
                    ),
                  );
                },
                child: const Text('Vote'),
              ),
            ),
          );
        },
      ),
    );
  }
}
