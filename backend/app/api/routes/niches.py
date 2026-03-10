from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.core.database import get_db
from app.models.niche_daily_metric import NicheDailyMetric
from app.models.niche import Niche

router = APIRouter(prefix="/api/niches", tags=["niches"])


@router.get("/trending")
def get_trending_niches(
    country: str = Query(..., description="Country code, contoh: ID"),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(NicheDailyMetric, Niche)
        .join(Niche, Niche.id == NicheDailyMetric.niche_id)
        .filter(NicheDailyMetric.country_code == country)
        .order_by(desc(NicheDailyMetric.opportunity_score))
        .limit(limit)
        .all()
    )

    result = []
    for metric, niche in rows:
        result.append(
            {
                "niche_id": niche.id,
                "niche_name": niche.cluster_name,
                "category": niche.category,
                "country_code": metric.country_code,
                "total_views": metric.total_views,
                "total_uploads": metric.total_uploads,
                "total_likes": metric.total_likes,
                "total_comments": metric.total_comments,
                "active_channels": metric.active_channels,
                "trend_score": metric.trend_score,
                "competition_score": metric.competition_score,
                "opportunity_score": metric.opportunity_score,
            }
        )
    return {"items": result}
