from pydantic import BaseModel


class TrendingNicheItem(BaseModel):
    niche_id: int
    niche_name: str
    category: str
    country_code: str
    total_views: int
    total_uploads: int
    total_likes: int
    total_comments: int
    active_channels: int
    trend_score: float
    competition_score: float
    opportunity_score: float

    class Config:
        from_attributes = True
