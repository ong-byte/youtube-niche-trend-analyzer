from sqlalchemy import Column, Integer, String
from app.core.database import Base


class Niche(Base):
    __tablename__ = "niches"

    id = Column(Integer, primary_key=True, index=True)
    seed_keyword = Column(String(120), unique=True, nullable=False, index=True)
    cluster_name = Column(String(120), nullable=False)
    category = Column(String(80), nullable=False)
