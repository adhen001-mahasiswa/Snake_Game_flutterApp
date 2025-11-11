import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const SnakeGameApp());

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGamePage(),
    );
  }
}

enum Direction { up, down, left, right }

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage>
    with SingleTickerProviderStateMixin {
  static const int rowCount = 20;
  static const int totalCells = rowCount * rowCount;

  List<int> snake = [45, 65, 85];
  int food = Random().nextInt(totalCells);
  Direction direction = Direction.down;

  bool isGameStarted = false;
  int score = 0;

  late Ticker _ticker;
  double elapsed = 0.0;
  double moveInterval = 0.15;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration elapsedTime) {
    if (!isGameStarted) return;
    elapsed += 1 / 60;
    if (elapsed >= moveInterval) {
      elapsed = 0;
      setState(moveSnake);
    } else {
      setState(() {});
    }
  }

  void startGame() {
    setState(() {
      isGameStarted = true;
      snake = [45, 65, 85];
      direction = Direction.down;
      food = Random().nextInt(totalCells);
      score = 0;
      elapsed = 0;
    });
    _ticker.start();
  }

  void moveSnake() {
    int newHead = snake.last;

    switch (direction) {
      case Direction.down:
        newHead += rowCount;
        break;
      case Direction.up:
        newHead -= rowCount;
        break;
      case Direction.left:
        newHead -= 1;
        break;
      case Direction.right:
        newHead += 1;
        break;
    }

    if (newHead >= totalCells) {
      newHead -= totalCells;
    } else if (newHead < 0) {
      newHead += totalCells;
    } else if (direction == Direction.left &&
        newHead % rowCount == rowCount - 1) {
      newHead += rowCount;
    } else if (direction == Direction.right && newHead % rowCount == 0) {
      newHead -= rowCount;
    }

    if (snake.contains(newHead)) {
      _ticker.stop();
      setState(() => isGameStarted = false);
      return;
    }

    snake.add(newHead);
    if (newHead == food) {
      food = Random().nextInt(totalCells);
      score++;
    } else {
      snake.removeAt(0);
    }
  }

  void restartGame() {
    _ticker.stop();
    startGame();
  }

  void backToMenu() {
    _ticker.stop();
    setState(() {
      isGameStarted = false;
      snake.clear();
      score = 0;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Score: $score",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isGameStarted)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: restartGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Restart",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: backToMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Menu",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCells,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowCount,
                  ),
                  itemBuilder: (context, index) {
                    if (!isGameStarted) {
                      return Container(color: Colors.grey[900]);
                    } else if (snake.contains(index)) {
                      bool isHead = index == snake.last;
                      return SnakeBlock(isHead: isHead);
                    } else if (index == food) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        color: Colors.grey[900],
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          if (isGameStarted)
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      if (direction != Direction.down) direction = Direction.up;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          if (direction != Direction.right) {
                            direction = Direction.left;
                          }
                        },
                      ),
                      const SizedBox(width: 50),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          if (direction != Direction.left) {
                            direction = Direction.right;
                          }
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      if (direction != Direction.up) direction = Direction.down;
                    },
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Mulai Game",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SnakeBlock extends StatelessWidget {
  final bool isHead;
  const SnakeBlock({super.key, this.isHead = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isHead ? Colors.lightGreenAccent : Colors.greenAccent,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
