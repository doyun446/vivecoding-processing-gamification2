⚫⚪ 오목 (Gomoku)

Processing으로 만든 오목 게임을 자바스크립트로 옮겨 웹에서 플레이할 수 있게 만든 프로젝트입니다.

🎮 플레이하기

👉 https://doyun446.github.io/vivecoding-processing-gamification2/

PC와 모바일 브라우저에서 모두 플레이할 수 있습니다.

📋 게임 규칙
15×15 바둑판에서 두 사람이 번갈아 돌을 놓습니다. (흑 선공)
가로, 세로, 대각선으로 5개 이상 먼저 연결하면 승리합니다.
판이 가득 차면 무승부입니다.
⌨️ 조작법
입력	동작
마우스 클릭 / 터치	돌 놓기
U 또는 Backspace	한 수 무르기
R	새 게임
✨ 기능
마우스를 올리면 놓을 위치를 반투명 돌로 미리 보여줌
마지막에 둔 수를 빨간 점으로 표시
승리하면 연결된 다섯 돌 위에 빨간 선 표시
무르기 / 새 게임 버튼
📁 파일 구성
파일	설명
index.html	웹 버전 (HTML + JavaScript Canvas)
Omok.pde	원본 Processing 버전
🛠️ 사용 기술
Processing (Java)
JavaScript, HTML5 Canvas
GitHub Pages
🔍 승리 판정 방식

돌을 놓을 때마다 그 돌을 기준으로 4방향(가로, 세로, ↘, ↙)의 양쪽으로 같은 색 돌이 몇 개 이어지는지 셉니다. 합이 5 이상이면 승리입니다.
