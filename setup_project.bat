@echo off
setlocal enabledelayedexpansion

echo Creating project structure...

mkdir backend 2>nul
mkdir backend\app 2>nul
mkdir backend\app\api 2>nul
mkdir backend\app\api\routes 2>nul
mkdir backend\app\core 2>nul
mkdir backend\app\models 2>nul
mkdir backend\app\schemas 2>nul
mkdir backend\app\services 2>nul
mkdir backend\scripts 2>nul

mkdir frontend 2>nul
mkdir frontend\app 2>nul
mkdir frontend\components 2>nul
mkdir frontend\lib 2>nul

echo Writing root files...

(
echo # Python
echo __pycache__/
echo *.pyc
echo .env
echo .venv/
echo.
echo # Node
echo node_modules/
echo .next/
echo.
echo # OS
echo .DS_Store
) > .gitignore

(
echo version: "3.9"
echo.
echo services:
echo   db:
echo     image: postgres:16
echo     container_name: yt_niche_db
echo     restart: unless-stopped
echo     environment:
echo       POSTGRES_DB: youtube_niche
echo       POSTGRES_USER: postgres
echo       POSTGRES_PASSWORD: postgres
echo     ports:
echo       - "5432:5432"
echo     volumes:
echo       - postgres_data:/var/lib/postgresql/data
echo.
echo   backend:
echo     build:
echo       context: ./backend
echo       dockerfile: Dockerfile
echo     container_name: yt_niche_backend
echo     command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
echo     volumes:
echo       - ./backend:/app
echo     ports:
echo       - "8000:8000"
echo     env_file:
echo       - ./backend/.env
echo     depends_on:
echo       - db
echo.
echo   frontend:
echo     image: node:20
echo     container_name: yt_niche_frontend
echo     working_dir: /app
echo     command: sh -c "npm install && npm run dev"
echo     volumes:
echo       - ./frontend:/app
echo     ports:
echo       - "3000:3000"
echo     environment:
echo       NEXT_PUBLIC_API_BASE: http://localhost:8000
echo     depends_on:
echo       - backend
echo.
echo volumes:
echo   postgres_data:
) > docker-compose.yml

echo Writing backend files...

(
echo fastapi==0.115.0
echo uvicorn[standard]==0.30.6
echo sqlalchemy==2.0.35
echo psycopg2-binary==2.9.9
echo pydantic==2.9.2
echo pydantic-settings==2.5.2
echo python-dotenv==1.0.1
echo requests==2.32.3
) > backend\requirements.txt

(
echo DATABASE_URL=postgresql+psycopg2://postgres:postgres@db:5432/youtube_niche
echo YOUTUBE_API_KEY=your_youtube_api_key
echo APP_NAME=YouTube Niche Trend Analyzer
echo APP_ENV=development
) > backend\.env.example

(
echo FROM python:3.11-slim
echo.
echo WORKDIR /app
echo COPY requirements.txt /app/requirements.txt
echo RUN pip install --no-cache-dir -r requirements.txt
echo COPY . /app
) > backend\Dockerfile

(
echo from pydantic_settings import BaseSettings, SettingsConfigDict
echo.
echo.
echo class Settings(BaseSettings^):
echo     app_name: str = "YouTube Niche Trend Analyzer"
echo     app_env: str = "development"
echo     database_url: str
echo     youtube_api_key: str = ""
echo.
echo     model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8"^)
echo.
echo.
echo settings = Settings(^)
) > backend\app\core\config.py

(
echo from sqlalchemy import create_engine
echo from sqlalchemy.orm import declarative_base, sessionmaker
echo from app.core.config import settings
echo.
echo.
echo engine = create_engine(settings.database_url, pool_pre_ping=True^)
echo SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine^)
echo Base = declarative_base(^)
echo.
echo.
echo def get_db(^):
echo     db = SessionLocal(^)
echo     try:
echo         yield db
echo     finally:
echo         db.close(^)
) > backend\app\core\database.py

(
echo from sqlalchemy import Column, Integer, String
echo from app.core.database import Base
echo.
echo.
echo class Country(Base^):
echo     __tablename__ = "countries"
echo.
echo     id = Column(Integer, primary_key=True, index=True^)
echo     code = Column(String(8^), unique=True, nullable=False, index=True^)
echo     name = Column(String(100^), nullable=False^)
echo     language = Column(String(20^), nullable=True^)
) > backend\app\models\country.py

(
echo from sqlalchemy import Column, Integer, String
echo from app.core.database import Base
echo.
echo.
echo class Niche(Base^):
echo     __tablename__ = "niches"
echo.
echo     id = Column(Integer, primary_key=True, index=True^)
echo     seed_keyword = Column(String(120^), unique=True, nullable=False, index=True^)
echo     cluster_name = Column(String(120^), nullable=False^)
echo     category = Column(String(80^), nullable=False^)
) > backend\app\models\niche.py

(
echo from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, BigInteger
echo from app.core.database import Base
echo.
echo.
echo class Video(Base^):
echo     __tablename__ = "videos"
echo.
echo     id = Column(Integer, primary_key=True, index=True^)
echo     youtube_video_id = Column(String(32^), unique=True, nullable=False, index=True^)
echo     title = Column(String(500^), nullable=False^)
echo     description = Column(String(5000^), nullable=True^)
echo     published_at = Column(DateTime, nullable=False^)
echo     channel_title = Column(String(255^), nullable=True^)
echo     niche_id = Column(Integer, ForeignKey("niches.id"^), nullable=False^)
echo     country_code = Column(String(8^), nullable=False, index=True^)
echo     language = Column(String(20^), nullable=True^)
echo     views = Column(BigInteger, default=0^)
echo     likes = Column(BigInteger, default=0^)
echo     comments = Column(BigInteger, default=0^)
) > backend\app\models\video.py

(
echo from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String, BigInteger
echo from app.core.database import Base
echo.
echo.
echo class NicheDailyMetric(Base^):
echo     __tablename__ = "niche_daily_metrics"
echo.
echo     id = Column(Integer, primary_key=True, index=True^)
echo     niche_id = Column(Integer, ForeignKey("niches.id"^), nullable=False, index=True^)
echo     country_code = Column(String(8^), nullable=False, index=True^)
echo     date = Column(Date, nullable=False, index=True^)
echo     total_views = Column(BigInteger, default=0^)
echo     total_uploads = Column(Integer, default=0^)
echo     total_likes = Column(BigInteger, default=0^)
echo     total_comments = Column(BigInteger, default=0^)
echo     active_channels = Column(Integer, default=0^)
echo     trend_score = Column(Float, default=0^)
echo     competition_score = Column(Float, default=0^)
echo     opportunity_score = Column(Float, default=0^)
) > backend\app\models\niche_daily_metric.py

(
echo from pydantic import BaseModel
echo.
echo.
echo class TrendingNicheItem(BaseModel^):
echo     niche_id: int
echo     niche_name: str
echo     category: str
echo     country_code: str
echo     total_views: int
echo     total_uploads: int
echo     total_likes: int
echo     total_comments: int
echo     active_channels: int
echo     trend_score: float
echo     competition_score: float
echo     opportunity_score: float
echo.
echo     class Config:
echo         from_attributes = True
) > backend\app\schemas\niche.py

(
echo def clamp(value: float, min_value: float = 0.0, max_value: float = 1.0^) -^> float:
echo     return max(min_value, min(value, max_value^)^)
echo.
echo.
echo def normalize(value: float, max_value: float^) -^> float:
echo     if max_value ^<= 0:
echo         return 0.0
echo     return clamp(value / max_value^)
echo.
echo.
echo def calculate_trend_score(
echo     view_growth_rate: float,
echo     upload_growth_rate: float,
echo     engagement_growth_rate: float,
echo     active_channel_growth_rate: float,
echo ^) -^> float:
echo     score = (
echo         0.35 * view_growth_rate
echo         + 0.25 * upload_growth_rate
echo         + 0.20 * engagement_growth_rate
echo         + 0.20 * active_channel_growth_rate
echo     ^)
echo     return round(clamp(score^), 4^)
echo.
echo.
echo def calculate_competition_score(
echo     active_channels_normalized: float,
echo     total_uploads_normalized: float,
echo     top_channels_concentration: float,
echo ^) -^> float:
echo     score = (
echo         0.5 * active_channels_normalized
echo         + 0.3 * total_uploads_normalized
echo         + 0.2 * top_channels_concentration
echo     ^)
echo     return round(clamp(score^), 4^)
echo.
echo.
echo def calculate_opportunity_score(trend_score: float, competition_score: float^) -^> float:
echo     return round(clamp(trend_score * (1 - competition_score^)^), 4^)
) > backend\app\services\scoring.py

(
echo from datetime import datetime
echo import requests
echo from app.core.config import settings
echo.
echo.
echo BASE_URL = "https://www.googleapis.com/youtube/v3"
echo.
echo.
echo class YouTubeCollector:
echo     def __init__(self^):
echo         self.api_key = settings.youtube_api_key
echo.
echo     def search_videos(self, keyword: str, country_code: str, max_results: int = 10^):
echo         url = f"{BASE_URL}/search"
echo         params = {
echo             "part": "snippet",
echo             "q": keyword,
echo             "type": "video",
echo             "regionCode": country_code,
echo             "maxResults": max_results,
echo             "order": "viewCount",
echo             "key": self.api_key,
echo         }
echo         response = requests.get(url, params=params, timeout=30^)
echo         response.raise_for_status(^)
echo         return response.json(^).get("items", []^)
echo.
echo     def get_video_stats(self, video_ids: list[str]^):
echo         if not video_ids:
echo             return []
echo         url = f"{BASE_URL}/videos"
echo         params = {
echo             "part": "statistics,snippet",
echo             "id": ",".join(video_ids^),
echo             "key": self.api_key,
echo         }
echo         response = requests.get(url, params=params, timeout=30^)
echo         response.raise_for_status(^)
echo         return response.json(^).get("items", []^)
echo.
echo     def collect_keyword_country_snapshot(self, keyword: str, country_code: str^):
echo         search_items = self.search_videos(keyword=keyword, country_code=country_code^)
echo         video_ids = [item["id"]["videoId"] for item in search_items if "videoId" in item.get("id", {}^)]
echo         stats_items = self.get_video_stats(video_ids^)
echo.
echo         results = []
echo         for item in stats_items:
echo             snippet = item.get("snippet", {}^)
echo             statistics = item.get("statistics", {}^)
echo             results.append(
echo                 {
echo                     "youtube_video_id": item["id"],
echo                     "title": snippet.get("title", ""^),
echo                     "description": snippet.get("description", ""^),
echo                     "published_at": datetime.fromisoformat(
echo                         snippet.get("publishedAt", "1970-01-01T00:00:00Z"^).replace("Z", "+00:00"^)
echo                     ^),
echo                     "channel_title": snippet.get("channelTitle", ""^),
echo                     "country_code": country_code,
echo                     "language": snippet.get("defaultLanguage"^) or snippet.get("defaultAudioLanguage"^),
echo                     "views": int(statistics.get("viewCount", 0^)^),
echo                     "likes": int(statistics.get("likeCount", 0^)^),
echo                     "comments": int(statistics.get("commentCount", 0^)^),
echo                 }
echo             ^)
echo         return results
) > backend\app\services\youtube_collector.py

(
echo from fastapi import APIRouter, Depends, Query
echo from sqlalchemy.orm import Session
echo from sqlalchemy import desc
echo.
echo from app.core.database import get_db
echo from app.models.niche_daily_metric import NicheDailyMetric
echo from app.models.niche import Niche
echo.
echo router = APIRouter(prefix="/api/niches", tags=["niches"]^)
echo.
echo.
echo @router.get("/trending"^)
echo def get_trending_niches(
echo     country: str = Query(..., description="Country code, contoh: ID"^),
echo     limit: int = Query(20, ge=1, le=100^),
echo     db: Session = Depends(get_db^),
echo ^):
echo     rows = (
echo         db.query(NicheDailyMetric, Niche^)
echo         .join(Niche, Niche.id == NicheDailyMetric.niche_id^)
echo         .filter(NicheDailyMetric.country_code == country^)
echo         .order_by(desc(NicheDailyMetric.opportunity_score^)^)
echo         .limit(limit^)
echo         .all(^)
echo     ^)
echo.
echo     result = []
echo     for metric, niche in rows:
echo         result.append(
echo             {
echo                 "niche_id": niche.id,
echo                 "niche_name": niche.cluster_name,
echo                 "category": niche.category,
echo                 "country_code": metric.country_code,
echo                 "total_views": metric.total_views,
echo                 "total_uploads": metric.total_uploads,
echo                 "total_likes": metric.total_likes,
echo                 "total_comments": metric.total_comments,
echo                 "active_channels": metric.active_channels,
echo                 "trend_score": metric.trend_score,
echo                 "competition_score": metric.competition_score,
echo                 "opportunity_score": metric.opportunity_score,
echo             }
echo         ^)
echo     return {"items": result}
) > backend\app\api\routes\niches.py

(
echo from fastapi import FastAPI
echo from fastapi.middleware.cors import CORSMiddleware
echo.
echo from app.api.routes.niches import router as niches_router
echo from app.core.config import settings
echo from app.core.database import Base, engine
echo from app.models.country import Country
echo from app.models.niche import Niche
echo from app.models.video import Video
echo from app.models.niche_daily_metric import NicheDailyMetric
echo.
echo.
echo Base.metadata.create_all(bind=engine^)
echo.
echo app = FastAPI(title=settings.app_name^)
echo.
echo app.add_middleware(
echo     CORSMiddleware,
echo     allow_origins=["http://localhost:3000"],
echo     allow_credentials=True,
echo     allow_methods=["*"],
echo     allow_headers=["*"],
echo ^)
echo.
echo app.include_router(niches_router^)
echo.
echo.
echo @app.get("/"^)
echo def root(^):
echo     return {
echo         "name": settings.app_name,
echo         "status": "ok",
echo         "env": settings.app_env,
echo     }
echo.
echo.
echo @app.post("/seed-demo"^)
echo def seed_demo(^):
echo     from scripts.seed_demo_data import run
echo     run(^)
echo     return {"message": "Demo data inserted"}
) > backend\app\main.py

(
echo from datetime import date
echo.
echo from app.core.database import SessionLocal
echo from app.models.country import Country
echo from app.models.niche import Niche
echo from app.models.niche_daily_metric import NicheDailyMetric
echo.
echo.
echo def run(^):
echo     db = SessionLocal(^)
echo.
echo     countries = [
echo         Country(code="ID", name="Indonesia", language="id"^),
echo         Country(code="US", name="United States", language="en"^),
echo         Country(code="IN", name="India", language="en"^),
echo     ]
echo.
echo     niches = [
echo         Niche(seed_keyword="ai tools", cluster_name="AI Tools", category="technology"^),
echo         Niche(seed_keyword="personal finance", cluster_name="Personal Finance", category="finance"^),
echo         Niche(seed_keyword="mobile gaming", cluster_name="Mobile Gaming", category="gaming"^),
echo     ]
echo.
echo     for country in countries:
echo         existing = db.query(Country^).filter(Country.code == country.code^).first(^)
echo         if not existing:
echo             db.add(country^)
echo.
echo     db.commit(^)
echo.
echo     for niche in niches:
echo         existing = db.query(Niche^).filter(Niche.seed_keyword == niche.seed_keyword^).first(^)
echo         if not existing:
echo             db.add(niche^)
echo.
echo     db.commit(^)
echo.
echo     all_niches = db.query(Niche^).all(^)
echo.
echo     demo_metrics = [
echo         ("ID", "AI Tools", 950000, 120, 55000, 4200, 45, 0.83, 0.31, 0.57^),
echo         ("ID", "Personal Finance", 720000, 90, 28000, 3500, 30, 0.69, 0.28, 0.50^),
echo         ("ID", "Mobile Gaming", 1500000, 220, 80000, 6500, 80, 0.78, 0.62, 0.30^),
echo         ("US", "AI Tools", 2800000, 260, 140000, 12000, 110, 0.88, 0.56, 0.39^),
echo         ("IN", "Mobile Gaming", 3100000, 340, 180000, 15000, 140, 0.91, 0.60, 0.36^),
echo     ]
echo.
echo     for country_code, niche_name, views, uploads, likes, comments, channels, trend, comp, opp in demo_metrics:
echo         niche = next((n for n in all_niches if n.cluster_name == niche_name^), None^)
echo         if not niche:
echo             continue
echo.
echo         exists = (
echo             db.query(NicheDailyMetric^)
echo             .filter(
echo                 NicheDailyMetric.niche_id == niche.id,
echo                 NicheDailyMetric.country_code == country_code,
echo                 NicheDailyMetric.date == date.today(^),
echo             ^)
echo             .first(^)
echo         ^)
echo         if exists:
echo             continue
echo.
echo         db.add(
echo             NicheDailyMetric(
echo                 niche_id=niche.id,
echo                 country_code=country_code,
echo                 date=date.today(^),
echo                 total_views=views,
echo                 total_uploads=uploads,
echo                 total_likes=likes,
echo                 total_comments=comments,
echo                 active_channels=channels,
echo                 trend_score=trend,
echo                 competition_score=comp,
echo                 opportunity_score=opp,
echo             ^)
echo         ^)
echo.
echo     db.commit(^)
echo     db.close(^)
echo     print("Demo data inserted."^)
echo.
echo.
echo if __name__ == "__main__":
echo     run(^)
) > backend\scripts\seed_demo_data.py

echo Writing frontend files...

(
echo {
echo   "name": "youtube-niche-trend-frontend",
echo   "version": "1.0.0",
echo   "private": true,
echo   "scripts": {
echo     "dev": "next dev",
echo     "build": "next build",
echo     "start": "next start"
echo   },
echo   "dependencies": {
echo     "next": "14.2.15",
echo     "react": "18.3.1",
echo     "react-dom": "18.3.1"
echo   },
echo   "devDependencies": {
echo     "typescript": "5.6.2",
echo     "@types/node": "22.7.4",
echo     "@types/react": "18.3.3",
echo     "@types/react-dom": "18.3.0"
echo   }
echo }
) > frontend\package.json

(
echo {
echo   "compilerOptions": {
echo     "target": "es2017",
echo     "lib": ["dom", "dom.iterable", "esnext"],
echo     "allowJs": false,
echo     "skipLibCheck": true,
echo     "strict": true,
echo     "noEmit": true,
echo     "esModuleInterop": true,
echo     "module": "esnext",
echo     "moduleResolution": "bundler",
echo     "resolveJsonModule": true,
echo     "isolatedModules": true,
echo     "jsx": "preserve",
echo     "incremental": true,
echo     "plugins": [{ "name": "next" }]
echo   },
echo   "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
echo   "exclude": ["node_modules"]
echo }
) > frontend\tsconfig.json

(
echo /** @type {import('next').NextConfig} */
echo const nextConfig = {
echo   reactStrictMode: true,
echo }
echo.
echo module.exports = nextConfig
) > frontend\next.config.js

(
echo const API_BASE = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";
echo.
echo export async function getTrendingNiches(country: string) {
echo   const response = await fetch(`${API_BASE}/api/niches/trending?country=${country}`, {
echo     cache: "no-store",
echo   });
echo.
echo   if (!response.ok) {
echo     throw new Error("Failed to fetch trending niches");
echo   }
echo.
echo   return response.json();
echo }
) > frontend\lib\api.ts

(
echo type Item = {
echo   niche_id: number;
echo   niche_name: string;
echo   category: string;
echo   country_code: string;
echo   total_views: number;
echo   total_uploads: number;
echo   total_likes: number;
echo   total_comments: number;
echo   active_channels: number;
echo   trend_score: number;
echo   competition_score: number;
echo   opportunity_score: number;
echo };
echo.
echo export default function TrendTable({ items }: { items: Item[] }) {
echo   return (
echo     ^<div style={{ overflowX: "auto", border: "1px solid #ddd", borderRadius: 12, padding: 12 }}^>
echo       ^<table style={{ width: "100%%", borderCollapse: "collapse" }}^>
echo         ^<thead^>
echo           ^<tr^>
echo             ^<th align="left"^>Niche^</th^>
echo             ^<th align="left"^>Category^</th^>
echo             ^<th align="right"^>Views^</th^>
echo             ^<th align="right"^>Uploads^</th^>
echo             ^<th align="right"^>Channels^</th^>
echo             ^<th align="right"^>Trend^</th^>
echo             ^<th align="right"^>Competition^</th^>
echo             ^<th align="right"^>Opportunity^</th^>
echo           ^</tr^>
echo         ^</thead^>
echo         ^<tbody^>
echo           {items.map((item^) =^> (
echo             ^<tr key={`${item.country_code}-${item.niche_id}`}^>
echo               ^<td^>{item.niche_name}^</td^>
echo               ^<td^>{item.category}^</td^>
echo               ^<td align="right"^>{item.total_views.toLocaleString(^)}^</td^>
echo               ^<td align="right"^>{item.total_uploads.toLocaleString(^)}^</td^>
echo               ^<td align="right"^>{item.active_channels.toLocaleString(^)}^</td^>
echo               ^<td align="right"^>{item.trend_score}^</td^>
echo               ^<td align="right"^>{item.competition_score}^</td^>
echo               ^<td align="right"^>{item.opportunity_score}^</td^>
echo             ^</tr^>
echo           )^)}
echo         ^</tbody^>
echo       ^</table^>
echo     ^</div^>
echo   ^);
echo }
) > frontend\components\TrendTable.tsx

(
echo import TrendTable from "@/components/TrendTable";
echo import { getTrendingNiches } from "@/lib/api";
echo.
echo export default async function Home() {
echo   const data = await getTrendingNiches("ID");
echo.
echo   return (
echo     ^<main style={{ maxWidth: 1200, margin: "0 auto", padding: 24, fontFamily: "Arial, sans-serif" }}^>
echo       ^<h1^>YouTube Niche Trend Analyzer^</h1^>
echo       ^<p^>MVP v1 - trending niche YouTube per negara.^</p^>
echo.
echo       ^<section style={{ marginTop: 24 }}^>
echo         ^<h2^>Trending Niches - Indonesia^</h2^>
echo         ^<TrendTable items={data.items || []} /^>
echo       ^</section^>
echo     ^</main^>
echo   ^);
echo }
) > frontend\app\page.tsx

(
echo html, body {
echo   margin: 0;
echo   padding: 0;
echo   background: #fafafa;
echo   color: #111;
echo }
echo.
echo * {
echo   box-sizing: border-box;
echo }
echo.
echo table th,
echo table td {
echo   padding: 10px;
echo   border-bottom: 1px solid #eee;
echo }
) > frontend\app\globals.css

(
echo /// ^<reference types="next" /^>
echo /// ^<reference types="next/image-types/global" /^>
echo.
echo // This file is auto-generated by Next.js
) > frontend\next-env.d.ts

echo Creating Python package marker files...

type nul > backend\app\__init__.py

echo Done.
echo.
echo Next:
echo 1. Copy backend\.env.example to backend\.env
echo 2. Run git init
echo 3. Push to GitHub
echo 4. Deploy
pause