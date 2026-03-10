from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, BigInteger
from app.core.database import Base


class Video(Base):
    __tablename__ = "videos"

    id = Column(Integer, primary_key=True, index=True)
    youtube_video_id = Column(String(32), unique=True, nullable=False, index=True)
    title = Column(String(500), nullable=False)
    description = Column(String(5000), nullable=True)
    published_at = Column(DateTime, nullable=False)
    channel_title = Column(String(255), nullable=True)
    niche_id = Column(Integer, ForeignKey("niches.id"), nullable=False)
    country_code = Column(String(8), nullable=False, index=True)
    language = Column(String(20), nullable=True)
    views = Column(BigInteger, default=0)
    likes = Column(BigInteger, default=0)
    comments = Column(BigInteger, default=0)
