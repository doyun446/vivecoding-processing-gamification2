// ===============================================
//  오목 (Gomoku) - Processing
//  - 15x15 바둑판, 2인용 (흑 선공)
//  - 가로/세로/대각선 5개 이상 연결 시 승리
//  - 마우스 클릭: 돌 놓기
//  - U 또는 BACKSPACE: 한 수 무르기
//  - R: 새 게임
// ===============================================

final int N = 15;          // 판 크기 (15줄)
final int CELL = 40;       // 칸 간격(px)
final int MARGIN = 40;     // 판 바깥 여백
final int INFO_H = 70;     // 아래 정보창 높이

final int EMPTY = 0, BLACK = 1, WHITE = 2;

int[][] board = new int[N][N];
int turn = BLACK;
int winner = EMPTY;
boolean draw = false;

ArrayList<int[]> history = new ArrayList<int[]>();  // {row, col}
int[] winStart = null, winEnd = null;               // 승리 줄 양 끝

PFont font;

void settings() {
  int boardPx = MARGIN * 2 + CELL * (N - 1);
  size(boardPx, boardPx + INFO_H);
  smooth(8);
}

void setup() {
  font = createFont("SansSerif", 20, true);  // 한글 표시용
  textFont(font);
  resetGame();
}

void resetGame() {
  for (int r = 0; r < N; r++)
    for (int c = 0; c < N; c++)
      board[r][c] = EMPTY;
  turn = BLACK;
  winner = EMPTY;
  draw = false;
  history.clear();
  winStart = winEnd = null;
}

// ------------------- 그리기 -------------------
void draw() {
  background(222, 184, 135);
  drawBoard();
  drawStones();
  drawHover();
  drawWinLine();
  drawInfo();
}

void drawBoard() {
  stroke(60);
  strokeWeight(1);
  for (int i = 0; i < N; i++) {
    float p = MARGIN + i * CELL;
    line(MARGIN, p, MARGIN + CELL * (N - 1), p);   // 가로줄
    line(p, MARGIN, p, MARGIN + CELL * (N - 1));   // 세로줄
  }
  // 화점 (천원 + 4귀)
  noStroke();
  fill(40);
  int[] pts = {3, 7, 11};
  for (int r : pts)
    for (int c : pts)
      if ((r == 7 && c == 7) || (r != 7 && c != 7))
        circle(gx(c), gy(r), 7);
}

void drawStones() {
  for (int r = 0; r < N; r++)
    for (int c = 0; c < N; c++)
      if (board[r][c] != EMPTY) drawStone(r, c, board[r][c], 255);

  // 마지막 수 표시
  if (history.size() > 0) {
    int[] last = history.get(history.size() - 1);
    noStroke();
    fill(220, 40, 40);
    circle(gx(last[1]), gy(last[0]), 8);
  }
}

void drawStone(int r, int c, int color_, float alpha) {
  float x = gx(c), y = gy(r), d = CELL * 0.88;
  noStroke();
  // 그림자
  fill(0, 60 * alpha / 255);
  circle(x + 2, y + 2, d);
  if (color_ == BLACK) {
    fill(20, alpha);
    circle(x, y, d);
    fill(90, alpha * 0.6);
    circle(x - d * 0.18, y - d * 0.18, d * 0.25);  // 하이라이트
  } else {
    fill(245, alpha);
    stroke(150, alpha);
    strokeWeight(1);
    circle(x, y, d);
  }
}

void drawHover() {
  if (winner != EMPTY || draw) return;
  int c = round((mouseX - MARGIN) / (float) CELL);
  int r = round((mouseY - MARGIN) / (float) CELL);
  if (inBoard(r, c) && board[r][c] == EMPTY)
    drawStone(r, c, turn, 110);   // 반투명 미리보기
}

void drawWinLine() {
  if (winStart == null) return;
  stroke(220, 30, 30);
  strokeWeight(5);
  line(gx(winStart[1]), gy(winStart[0]), gx(winEnd[1]), gy(winEnd[0]));
}

void drawInfo() {
  float top = height - INFO_H;
  noStroke();
  fill(50);
  rect(0, top, width, INFO_H);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(22);
  String msg;
  if (winner == BLACK)      msg = "흑 승리!  (R: 새 게임)";
  else if (winner == WHITE) msg = "백 승리!  (R: 새 게임)";
  else if (draw)            msg = "무승부  (R: 새 게임)";
  else                      msg = (turn == BLACK ? "흑" : "백") + " 차례  ·  " + (history.size() + 1) + "수";
  text(msg, width / 2, top + INFO_H * 0.38);

  textSize(13);
  fill(190);
  text("클릭: 착수   U / Backspace: 무르기   R: 새 게임", width / 2, top + INFO_H * 0.75);
}

// ------------------- 입력 -------------------
void mousePressed() {
  if (winner != EMPTY || draw) return;
  int c = round((mouseX - MARGIN) / (float) CELL);
  int r = round((mouseY - MARGIN) / (float) CELL);
  if (!inBoard(r, c) || board[r][c] != EMPTY) return;

  board[r][c] = turn;
  history.add(new int[]{r, c});

  if (checkWin(r, c)) {
    winner = turn;
  } else if (history.size() == N * N) {
    draw = true;
  } else {
    turn = (turn == BLACK) ? WHITE : BLACK;
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetGame();
  } else if (key == 'u' || key == 'U' || key == BACKSPACE) {
    undo();
  }
}

void undo() {
  if (history.size() == 0) return;
  int[] last = history.remove(history.size() - 1);
  turn = board[last[0]][last[1]];   // 무른 돌의 주인이 다시 둔다
  board[last[0]][last[1]] = EMPTY;
  winner = EMPTY;
  draw = false;
  winStart = winEnd = null;
}

// ------------------- 승리 판정 -------------------
// 방금 둔 (r, c)에서 4방향으로 같은 색이 몇 개 이어지는지 센다.
boolean checkWin(int r, int c) {
  int me = board[r][c];
  int[][] dirs = {{0, 1}, {1, 0}, {1, 1}, {1, -1}};  // 가로, 세로, ↘, ↙
  for (int[] d : dirs) {
    int count = 1;
    int r1 = r, c1 = c, r2 = r, c2 = c;
    // 정방향
    while (inBoard(r2 + d[0], c2 + d[1]) && board[r2 + d[0]][c2 + d[1]] == me) {
      r2 += d[0]; c2 += d[1]; count++;
    }
    // 역방향
    while (inBoard(r1 - d[0], c1 - d[1]) && board[r1 - d[0]][c1 - d[1]] == me) {
      r1 -= d[0]; c1 -= d[1]; count++;
    }
    if (count >= 5) {
      winStart = new int[]{r1, c1};
      winEnd = new int[]{r2, c2};
      return true;
    }
  }
  return false;
}

// ------------------- 유틸 -------------------
boolean inBoard(int r, int c) { return r >= 0 && r < N && c >= 0 && c < N; }
float gx(int c) { return MARGIN + c * CELL; }
float gy(int r) { return MARGIN + r * CELL; }
