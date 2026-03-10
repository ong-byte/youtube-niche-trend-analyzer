from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.niches import router as niches_router
from app.core.config import settings
from app.core.database import Base, engine
from app.models.country import Country
from app.models.niche import Niche
from app.models.video import Video
from app.models.niche_daily_metric import NicheDailyMetric


Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.app_name)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(niches_router)


@app.get("/")
def root():
    return {
        "name": settings.app_name,
        "status": "ok",
        "env": settings.app_env,
    }


@app.post("/seed-demo")
def seed_demo():
    from scripts.seed_demo_data import run
    run()
    return {"message": "Demo data inserted"}
