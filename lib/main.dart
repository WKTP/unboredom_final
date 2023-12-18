import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Unboredom(),
    );
  }
}

class Unboredom extends StatefulWidget {
  const Unboredom({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UnboredomGameState createState() => _UnboredomGameState();
}

class _UnboredomGameState extends State<Unboredom> {
  late List<List<bool>> isMine;
  late List<List<int>> adjacentMines;
  late List<List<bool>> isCellRevealed;
  int rows = 10;
  int columns = 10;
  // late int totalNonMineCells;
  int revealedNonMineCells = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    setState(() {});
    // reset winning condition
    revealedNonMineCells = 0;
    // create 2D list for mine/adjacent/reveal
    isMine = List.generate(rows, (i) => List<bool>.filled(columns, false));
    adjacentMines = List.generate(rows, (i) => List<int>.filled(columns, 0));
    isCellRevealed =
        List.generate(rows, (i) => List<bool>.filled(columns, false));

    placeMines();

    calculateAdjacentMines();
  }

  void placeMines() {
    // randomly place mines
    Random random = Random();
    int minesToPlace =
        (rows * columns * 0.1).round(); // 10% of cells contains mines

    for (int i = 0; i < minesToPlace; i++) {
      int randomRow = random.nextInt(rows);
      int randomCol = random.nextInt(columns);
      if (!isMine[randomRow][randomCol]) {
        isMine[randomRow][randomCol] = true;
      } else {
        // If cell already placed, try again
        i--;
      }
    }
  }

  void calculateAdjacentMines() {
    // check into every cell in 8x8 grid
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        // If isnt mine, count adjacent
        if (!isMine[row][col]) {
          // check 3x3 around the cell for counting adjacent mines
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              int pointerRow = row + i;
              int pointerCol = col + j;
              // fix index out of bound
              if (pointerRow >= 0 &&
                  pointerRow < rows &&
                  pointerCol >= 0 &&
                  pointerCol < columns) {
                // if points at mine, +1 to the started cell (row,col)
                if (isMine[pointerRow][pointerCol]) {
                  adjacentMines[row][col]++;
                }
              }
            }
          }
        }
      }
    }
  }

  void revealCell(int row, int col) {
    // fix index out of bound and already revealed cell
    if (row < 0 ||
        row >= rows ||
        col < 0 ||
        col >= columns ||
        isCellRevealed[row][col]) {
      return;
    }

    // revealing
    isCellRevealed[row][col] = true;

    // win condition
    revealedNonMineCells++;

    // check 3x3, if the cell is 0
    if (adjacentMines[row][col] == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          revealCell(row + i, col + j);
        }
      }
    }
  }

  void _showPopup(String popupTitle, String popupMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(popupTitle),
          content: Text(popupMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                initializeGame();
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  void checkWinningCondition() {
    int i = (rows * columns) - (rows * columns * 0.1).round();
    // Check if the player has revealed all non-mine cells
    if (revealedNonMineCells == i) {
      _showPopup('ชนะแล้ววว♥', "โคตรเก่งโคตรเจ๋ง!!!");
    }
  }

  Widget buildCell(int row, int col) {
    // state for each cell
    bool hasMine = isMine[row][col];
    int adjacent = adjacentMines[row][col];
    bool revealed = isCellRevealed[row][col];

    return GestureDetector(
      onTap: () {
        // Handle cell tap
        setState(() {
          if (!revealed) {
            revealCell(row, col);
            checkWinningCondition();
          }
        });

        if (hasMine) {
          // exposed all cell when lose
          for (int i = 0; i < rows; i++) {
            for (int j = 0; j < columns; j++) {
              revealCell(i, j);
            }
          }
          _showPopup(
              "อ่อนหัด!!!", "ยังเร็วไปร้อยปีไอน้อง ไปฝึกมาใหม่นะ ฮ่าๆๆๆ");
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(),
          color: revealed
              ? Colors.grey[200] // color revealed
              : Colors.orange[200], // color not revealed
        ),
        child: Center(
          child: Text(
            revealed
                ? (hasMine ? "💣" : (adjacent > 0 ? '$adjacent' : ''))
                : '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasMine ? Colors.black : Colors.black, //
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unboredom'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: List.generate(
                rows,
                (row) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    columns,
                    (col) => buildCell(row, col),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: initializeGame, child: const Text("Restart"))
          ],
        ),
      ),
    );
  }
}
