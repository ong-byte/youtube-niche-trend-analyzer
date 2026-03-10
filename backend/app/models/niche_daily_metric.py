from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String, BigInteger
from app.core.database import Base


class NicheDailyMetric(Base):
    __tablename__ = "niche_daily_metrics"

    id = Column(Integer, primary_key=True, index=True)
    niche_id = Column(Integer, ForeignKey("niches.id"), nullable=False, index=True)
    country_code = Column(String(8), nullable=False, index=True)
    date = Column(Date, nullable=False, index=True)
    total_views = Column(BigInteger, default=0)
    total_uploads = Column(Integer, default=0)
    total_likes = Column(BigInteger, default=0)
    total_comments = Column(BigInteger, default=0)
    active_channels = Column(Integer, default=0)
    trend_score = Column(Float, default=0)
    competition_score = Column(Float, default=0)
    opportunity_score = Column(Float, default=0)
