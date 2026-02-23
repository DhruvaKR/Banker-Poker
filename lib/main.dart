import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const PokerApp());
}

class PokerApp extends StatefulWidget {
  const PokerApp({super.key});

  @override
  State<PokerApp> createState() => _PokerAppState();
}

class _PokerAppState extends State<PokerApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() => isDark = !isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // 🌞 LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        cardColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      // 🌙 DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      home: SetupScreen(toggleTheme: toggleTheme),
    );
  }
}

class SetupScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SetupScreen({super.key, required this.toggleTheme});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final chips = TextEditingController();
  final money = TextEditingController();
  final initial = TextEditingController();
  final rebuy = TextEditingController();
  final ret = TextEditingController();

  void start() {
    if (chips.text.isEmpty ||
        money.text.isEmpty ||
        initial.text.isEmpty ||
        rebuy.text.isEmpty ||
        ret.text.isEmpty) {
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all values before starting the game ⚠️"),
        ),
      );

      return;
    }

    double chipValue = double.parse(money.text) / double.parse(chips.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          chipValue: chipValue,
          initial: int.parse(initial.text),
          rebuy: int.parse(rebuy.text),
          ret: int.parse(ret.text),
          toggleTheme: widget.toggleTheme,
        ),
      ),
    );
  }

  Widget input(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Setup"),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              widget.toggleTheme();
            },
            icon: const Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🎯 CHIP CONFIG CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chip Configuration",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: chips,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Total Chips",
                        prefixIcon: Icon(Icons.blur_circular),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: money,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Total Money (₹)",
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 👥 PLAYER CONFIG CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Player Settings",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: initial,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Initial Chips per Player",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: rebuy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Rebuy Chips",
                        prefixIcon: Icon(Icons.add_circle),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: ret,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Return Chips",
                        prefixIcon: Icon(Icons.undo),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🚀 START BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: start,
              child: const Text("Start Game", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final double chipValue;
  final int initial, rebuy, ret;
  final VoidCallback toggleTheme;

  const GameScreen({
    super.key,
    required this.chipValue,
    required this.initial,
    required this.rebuy,
    required this.ret,
    required this.toggleTheme,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final name = TextEditingController();
  List<Map<String, dynamic>> undoStack = [];
  List<Map<String, dynamic>> redoStack = [];
  List<Map<String, dynamic>> players = [];

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(players);
    await prefs.setString("game_data", data);
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString("game_data");

    if (data != null) {
      setState(() {
        players = List<Map<String, dynamic>>.from(
          jsonDecode(data).map(
            (p) => {
              "name": p["name"],
              "bought": p["bought"] ?? 0,
              "returned": p["returned"] ?? 0,
              "final": p["final"] ?? 0,
            },
          ),
        );
      });
    }
  }

  Future<void> clearOldData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  void initState() {
    super.initState();
    loadGame();
  }

  void undoAction() {
    if (undoStack.isEmpty) return;

    final action = undoStack.removeLast();

    int index = action["index"] ?? -1;
    int value = action["value"] ?? 0;
    String type = action["type"] ?? "";

    if (index < 0 || index >= players.length) return;

    setState(() {
      if (type == "rebuy") {
        players[index]["bought"] -= value;
      } else if (type == "return") {
        players[index]["returned"] -= value;
      }

      redoStack.add(action);
    });

    saveGame();
    HapticFeedback.selectionClick();
  }

  void redoAction() {
    if (redoStack.isEmpty) return;

    final action = redoStack.removeLast();

    int index = action["index"] ?? -1;
    int value = action["value"] ?? 0;
    String type = action["type"] ?? "";

    if (index < 0 || index >= players.length) return;

    setState(() {
      if (type == "rebuy") {
        players[index]["bought"] += value;
      } else if (type == "return") {
        players[index]["returned"] += value;
      }

      undoStack.add(action);
    });

    saveGame();
    HapticFeedback.selectionClick();
  }

  void addPlayer() {
    if (name.text.isEmpty) return;

    setState(() {
      players.add({
        "name": name.text,
        "bought": widget.initial,
        "returned": 0,
        "final": 0,
      });
    });
    saveGame();
    name.clear();
  }

  double profit(p) =>
      (p["returned"] + p["final"] - p["bought"]) * widget.chipValue;

  @override
  Widget build(BuildContext context) {
    double totalBought = 0;
    double totalReturned = 0;

    for (var p in players) {
      totalBought += p["bought"];
      totalReturned += (p["returned"] + p["final"]);
    }

    double totalSpent = totalBought * widget.chipValue;
    double totalValue = totalReturned * widget.chipValue;
    double net = totalValue - totalSpent;

    List<Map<String, dynamic>> winners = [];
    List<Map<String, dynamic>> losers = [];

    if (players.isNotEmpty) {
      double maxProfit = players
          .map((p) => profit(p))
          .reduce((a, b) => a > b ? a : b);

      double minProfit = players
          .map((p) => profit(p))
          .reduce((a, b) => a < b ? a : b);

      winners = players.where((p) => profit(p) == maxProfit).toList();

      losers = players.where((p) => profit(p) == minProfit).toList();
    }

    return WillPopScope(
      onWillPop: () async {
        HapticFeedback.mediumImpact();

        bool? exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Game"),
            content: const Text("Are you sure you want to go back?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        );

        return exit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Poker Tracker"),
          actions: [
            // 🔙 UNDO
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: undoStack.isEmpty ? null : undoAction,
            ),

            // 🔁 REDO
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: redoStack.isEmpty ? null : redoAction,
            ),

            // 🌙 THEME
            IconButton(
              onPressed: widget.toggleTheme,
              icon: const Icon(Icons.dark_mode),
            ),

            // 🧹 RESET
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                HapticFeedback.heavyImpact();

                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Reset Game"),
                    content: const Text(
                      "Are you sure you want to restart? All data will be lost.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  setState(() {
                    players.clear();
                    undoStack.clear();
                    redoStack.clear();
                  });
                  saveGame();
                }
              },
            ),
          ],
        ),

        body: Column(
          children: [
            // 📊 SUMMARY CARD
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                children: [
                  const Text(
                    "Game Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("Total Invested: ₹${totalSpent.toStringAsFixed(0)}"),
                  Text("Total Returned: ₹${totalValue.toStringAsFixed(0)}"),
                  Text(
                    "Net: ₹${net.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: net >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ➕ ADD PLAYER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: "Player Name"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      addPlayer();
                    },
                    child: const Text("Add Player"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 📋 PLAYER LIST
            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text(
                        "No players yet... even ghosts don't play alone 👻",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (_, i) {
                        var p = players[i];
                        var pr = profit(p);

                        bool isWinner = winners.contains(p);

                        return Dismissible(
                          key: Key(p["name"] + i.toString()),
                          direction: DismissDirection.endToStart,

                          // 🔴 Swipe background
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          confirmDismiss: (direction) async {
                            HapticFeedback.mediumImpact();

                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Player"),
                                content: Text("Remove ${p["name"]}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },

                          onDismissed: (direction) {
                            final removedPlayer = players[i];

                            setState(() {
                              players.removeAt(i);
                            });

                            saveGame();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${removedPlayer["name"]} removed",
                                ),
                                action: SnackBarAction(
                                  label: "UNDO",
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      players.insert(i, removedPlayer);
                                    });
                                    saveGame();
                                  },
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },

                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🧑 NAME + WINNER
                                  Row(
                                    children: [
                                      if (isWinner)
                                        const Text(
                                          "👑 ",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      Text(
                                        p["name"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // 💰 PROFIT
                                  Text(
                                    "₹${pr.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: pr >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 🎯 FINAL CHIPS INPUT (IMPORTANT)
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Final Chips Returning",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        p["final"] = int.tryParse(value) ?? 0;
                                      });
                                      saveGame();
                                    },
                                  ),

                                  const SizedBox(height: 10),

                                  // 🔘 BUTTONS
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              undoStack.add({
                                                "type": "rebuy",
                                                "index": i,
                                                "value": widget.rebuy,
                                              });

                                              redoStack.clear(); // 🔥 important

                                              p["bought"] += widget.rebuy;
                                            });
                                            saveGame();
                                          },
                                          child: const Text("Rebuy Chips 🔄"),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              undoStack.add({
                                                "type": "return",
                                                "index": i,
                                                "value": widget.ret,
                                              });

                                              redoStack.clear(); // 🔥 important

                                              p["returned"] += widget.ret;
                                            });
                                            saveGame();
                                          },
                                          child: const Text("Return Chips 💸"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (players.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: Theme.of(context).brightness == Brightness.dark
                      ? const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                        ),
                ),
                child: Builder(
                  builder: (context) {
                    // 👉 Prepare names
                    String winnerNames = winners
                        .map((e) => e["name"])
                        .join(", ");

                    String loserNames = losers.map((e) => e["name"]).join(", ");

                    // 👉 Grammar
                    String winnerLine = winners.length == 1
                        ? "$winnerNames is acting like a pro 😂"
                        : "$winnerNames are acting like pros 😂";

                    String loserLine = losers.length == 1
                        ? "$loserNames is feeding the table 🤣"
                        : "$loserNames are feeding the table 🤣";

                    return Column(
                      children: [
                        // 👑 Winner
                        Row(
                          children: [
                            const Text("👑 ", style: TextStyle(fontSize: 18)),
                            Expanded(
                              child: Text(
                                players.length == 1
                                    ? "😂 You're playing solo legend!"
                                    : winnerLine,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // 🐟 Loser
                        if (players.length > 1)
                          Row(
                            children: [
                              const Text("🐟 ", style: TextStyle(fontSize: 18)),
                              Expanded(child: Text(loserLine)),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
