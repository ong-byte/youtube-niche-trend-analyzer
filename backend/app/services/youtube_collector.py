from datetime import datetime
import requests
from app.core.config import settings


BASE_URL = "https://www.googleapis.com/youtube/v3"


class YouTubeCollector:
    def __init__(self):
        self.api_key = settings.youtube_api_key

    def search_videos(self, keyword: str, country_code: str, max_results: int = 10):
        url = f"{BASE_URL}/search"
        params = {
            "part": "snippet",
            "q": keyword,
            "type": "video",
            "regionCode": country_code,
            "maxResults": max_results,
            "order": "viewCount",
            "key": self.api_key,
        }
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        return response.json().get("items", [])

    def get_video_stats(self, video_ids: list[str]):
        if not video_ids:
            return []
        url = f"{BASE_URL}/videos"
        params = {
            "part": "statistics,snippet",
            "id": ",".join(video_ids),
            "key": self.api_key,
        }
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        return response.json().get("items", [])

    def collect_keyword_country_snapshot(self, keyword: str, country_code: str):
        search_items = self.search_videos(keyword=keyword, country_code=country_code)
        video_ids = [item["id"]["videoId"] for item in search_items if "videoId" in item.get("id", {})]
        stats_items = self.get_video_stats(video_ids)

        results = []
        for item in stats_items:
            snippet = item.get("snippet", {})
            statistics = item.get("statistics", {})
            results.append(
                {
                    "youtube_video_id": item["id"],
                    "title": snippet.get("title", ""),
                    "description": snippet.get("description", ""),
                    "published_at": datetime.fromisoformat(
                        snippet.get("publishedAt", "1970-01-01T00:00:00Z").replace("Z", "+00:00")
                    ),
                    "channel_title": snippet.get("channelTitle", ""),
                    "country_code": country_code,
                    "language": snippet.get("defaultLanguage") or snippet.get("defaultAudioLanguage"),
                    "views": int(statistics.get("viewCount", 0)),
                    "likes": int(statistics.get("likeCount", 0)),
                    "comments": int(statistics.get("commentCount", 0)),
                }
            )
        return results
