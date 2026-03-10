from sqlalchemy import Column, Integer, String
from app.core.database import Base


class Country(Base):
    __tablename__ = "countries"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(8), unique=True, nullable=False, index=True)
    name = Column(String(100), nullable=False)
    language = Column(String(20), nullable=True)
