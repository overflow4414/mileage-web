# ✈️ 대한항공 마일리지 스캐너

인천(ICN) 출발 대한항공 마일리지 보너스 좌석 가능 날짜를 자동으로 스캔하여 보여주는 웹 대시보드입니다.

🌐 **라이브 사이트**: https://overflow4414.github.io/mileage-web/

---

## 📋 특징

- ✅ **6개 주요 노선** 자동 스캔
  - 🇺🇸 미국: LAX, SFO, LAS
  - 🇪🇺 유럽: LHR, FRA, CDG
  
- ✅ **실시간 필터링**
  - 도착지별 필터
  - 클래스별 필터 (전체/퍼스티/프레스티지/일반석)
  
- ✅ **깔끔한 UI**
  - 반응형 디자인 (모바일/태블릿/데스크톱)
  - 날짜별 캘린더 뷰
  - 클래스별 색상 구분

- ✅ **자동 업데이트**
  - 정기적으로 최신 데이터 크롤링
  - GitHub Actions로 자동 배포

---

## 🛠 기술 스택

- **Frontend**: HTML + TailwindCSS + Vanilla JS
- **Backend**: Python (Playwright 크롤러)
- **Hosting**: GitHub Pages
- **Automation**: GitHub Actions (optional)

---

## 📦 설치 & 실행

### 1. 크롤러 설치

```bash
# web-automation 프로젝트로 이동
cd projects/web-automation

# uv 설치 (없다면)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 의존성 설치
uv sync

# 대한항공 로그인 (최초 1회)
uv run ke-login
```

### 2. 수동 스캔 실행

```bash
# mileage-web 디렉토리로 이동
cd projects/mileage-web

# 배포 스크립트 실행
./deploy.sh
```

스크립트는 다음을 수행합니다:
1. 6개 노선 크롤링 (6개월치)
2. 결과를 `data.json`으로 병합
3. Git commit & push

### 3. 로컬 미리보기

```bash
# 간단한 HTTP 서버 실행
python3 -m http.server 8000

# 브라우저에서 열기
open http://localhost:8000
```

---

## 🤖 자동화 설정

### Cron으로 정기 업데이트

```bash
# 매일 오전 9시에 스캔 실행
crontab -e
```

다음 추가:
```cron
0 9 * * * cd /Users/eunsungjo/clawd/projects/mileage-web && ./deploy.sh >> /tmp/mileage-deploy.log 2>&1
```

### GitHub Actions (선택사항)

`.github/workflows/update.yml`:

```yaml
name: Update Mileage Data

on:
  schedule:
    - cron: '0 0 * * *'  # 매일 자정 (UTC)
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install uv
          cd ../web-automation && uv sync
      
      - name: Run scan
        run: ./deploy.sh
      
      - name: Commit & Push
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git push
```

---

## 📁 파일 구조

```
mileage-web/
├── index.html          # 웹 대시보드 UI
├── data.json           # 크롤링 결과 (자동 생성)
├── merge_data.py       # 스캔 결과 병합 스크립트
├── deploy.sh           # 배포 자동화 스크립트
└── README.md           # 이 파일

web-automation/
└── src/web_automation/
    └── ke_scan.py      # 대한항공 크롤러
```

---

## 🎯 지원 노선

| 코드 | 도시 | 영문명 |
|------|------|--------|
| LAX | 로스앤젤레스 | Los Angeles |
| SFO | 샌프란시스코 | San Francisco |
| LAS | 라스베가스 | Las Vegas |
| LHR | 런던 히드로 | London Heathrow |
| FRA | 프랑크푸르트 | Frankfurt |
| CDG | 파리 샤를드골 | Paris CDG |

노선 추가를 원하면 `web-automation/src/web_automation/ke_scan.py`의 `DEFAULT_ROUTES` 수정 후 `deploy.sh` 재실행.

---

## 🐛 트러블슈팅

### "Missing storage state" 에러
```bash
cd projects/web-automation
uv run ke-login  # 브라우저에서 대한항공 로그인 진행
```

### 크롤링 실패 (봇 차단)
- `deploy.sh`의 `--headless` 제거하여 GUI 모드로 실행
- 대한항공 사이트가 IP 차단했을 수 있음 → 잠시 후 재시도

### data.json이 비어있음
```bash
# 수동으로 한 노선만 테스트
cd projects/web-automation
uv run ke-scan scan --months 6 --routes ICN-LAX --classes business,first
```

---

## 📊 데이터 형식

### data.json 구조
```json
{
  "updatedAt": "2026-02-01 09:00:00 KST",
  "routes": {
    "ICN-LAX": {
      "2026-05-01": ["business"],
      "2026-05-15": ["business", "first"]
    },
    "ICN-LHR": {
      "2026-06-10": ["first"]
    }
  }
}
```

### 클래스 타입
- `first`: 퍼스트
- `business` / `prestige`: 프레스티지 (비즈니스)
- `economy`: 일반석
- `premium_economy`: 프리미엄 이코노미

---

## 📝 라이선스

MIT License - 자유롭게 사용하세요!

---

## 🤝 기여

이슈 및 PR 환영합니다:
- 버그 제보
- 새로운 노선 추가 요청
- UI 개선 제안

---

## ⚠️ 면책조항

이 프로젝트는 개인 프로젝트이며, 참고용 데이터를 제공합니다.  
정확한 정보는 반드시 [대한항공 공식 사이트](https://www.koreanair.com)에서 확인하세요.

---

**Made with ❤️ by overflow4414**
