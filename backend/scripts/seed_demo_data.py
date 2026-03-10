from datetime import date

from app.core.database import SessionLocal
from app.models.country import Country
from app.models.niche import Niche
from app.models.niche_daily_metric import NicheDailyMetric


def run():
    db = SessionLocal()

    countries = [
        Country(code="ID", name="Indonesia", language="id"),
        Country(code="US", name="United States", language="en"),
        Country(code="IN", name="India", language="en"),
    ]

    niches = [
        Niche(seed_keyword="ai tools", cluster_name="AI Tools", category="technology"),
        Niche(seed_keyword="personal finance", cluster_name="Personal Finance", category="finance"),
        Niche(seed_keyword="mobile gaming", cluster_name="Mobile Gaming", category="gaming"),
    ]

    for country in countries:
        existing = db.query(Country).filter(Country.code == country.code).first()
        if not existing:
            db.add(country)

    db.commit()

    for niche in niches:
        existing = db.query(Niche).filter(Niche.seed_keyword == niche.seed_keyword).first()
        if not existing:
            db.add(niche)

    db.commit()

    all_niches = db.query(Niche).all()

    demo_metrics = [
        ("ID", "AI Tools", 950000, 120, 55000, 4200, 45, 0.83, 0.31, 0.57),
        ("ID", "Personal Finance", 720000, 90, 28000, 3500, 30, 0.69, 0.28, 0.50),
        ("ID", "Mobile Gaming", 1500000, 220, 80000, 6500, 80, 0.78, 0.62, 0.30),
        ("US", "AI Tools", 2800000, 260, 140000, 12000, 110, 0.88, 0.56, 0.39),
        ("IN", "Mobile Gaming", 3100000, 340, 180000, 15000, 140, 0.91, 0.60, 0.36),
    ]

    for country_code, niche_name, views, uploads, likes, comments, channels, trend, comp, opp in demo_metrics:
        niche = next((n for n in all_niches if n.cluster_name == niche_name), None)
        if not niche:
            continue

        exists = (
            db.query(NicheDailyMetric)
            .filter(
                NicheDailyMetric.niche_id == niche.id,
                NicheDailyMetric.country_code == country_code,
                NicheDailyMetric.date == date.today(),
            )
            .first()
        )
        if exists:
            continue

        db.add(
            NicheDailyMetric(
                niche_id=niche.id,
                country_code=country_code,
                date=date.today(),
                total_views=views,
                total_uploads=uploads,
                total_likes=likes,
                total_comments=comments,
                active_channels=channels,
                trend_score=trend,
                competition_score=comp,
                opportunity_score=opp,
            )
        )

    db.commit()
    db.close()
    print("Demo data inserted.")


if __name__ == "__main__":
    run()
