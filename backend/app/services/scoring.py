def clamp(value: float, min_value: float = 0.0, max_value: float = 1.0) -> float:
    return max(min_value, min(value, max_value))


def normalize(value: float, max_value: float) -> float:
    if max_value <= 0:
        return 0.0
    return clamp(value / max_value)


def calculate_trend_score(
    view_growth_rate: float,
    upload_growth_rate: float,
    engagement_growth_rate: float,
    active_channel_growth_rate: float,
) -> float:
    score = (
        0.35 * view_growth_rate
        + 0.25 * upload_growth_rate
        + 0.20 * engagement_growth_rate
        + 0.20 * active_channel_growth_rate
    )
    return round(clamp(score), 4)


def calculate_competition_score(
    active_channels_normalized: float,
    total_uploads_normalized: float,
    top_channels_concentration: float,
) -> float:
    score = (
        0.5 * active_channels_normalized
        + 0.3 * total_uploads_normalized
        + 0.2 * top_channels_concentration
    )
    return round(clamp(score), 4)


def calculate_opportunity_score(trend_score: float, competition_score: float) -> float:
    return round(clamp(trend_score * (1 - competition_score)), 4)
