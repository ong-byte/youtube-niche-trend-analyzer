"use client";

import { useEffect, useState } from "react";
import TrendTable from "../components/TrendTable";

type Item = {
  niche_id: number;
  niche_name: string;
  category: string;
  country_code: string;
  total_views: number;
  total_uploads: number;
  total_likes: number;
  total_comments: number;
  active_channels: number;
  trend_score: number;
  competition_score: number;
  opportunity_score: number;
};

export default function Home() {
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const apiBase = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";

    fetch(`${apiBase}/api/niches/trending?country=ID`)
      .then((res) => {
        if (!res.ok) {
          throw new Error("Failed to fetch trending niches");
        }
        return res.json();
      })
      .then((data) => {
        setItems(data.items || []);
      })
      .catch((err) => {
        setError(err.message || "Fetch failed");
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  return (
    <main style={{ maxWidth: 1200, margin: "0 auto", padding: 24, fontFamily: "Arial, sans-serif" }}>
      <h1>YouTube Niche Trend Analyzer</h1>
      <p>MVP v1 - trending niche YouTube per negara.</p>

      <section style={{ marginTop: 24 }}>
        <h2>Trending Niches - Indonesia</h2>

        {loading && <p>Loading data...</p>}
        {error && <p style={{ color: "red" }}>Error: {error}</p>}
        {!loading && !error && <TrendTable items={items} />}
      </section>
    </main>
  );
}