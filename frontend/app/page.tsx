import TrendTable from "../components/TrendTable";
import { getTrendingNiches } from "../lib/api";

export default async function Home() {
  const data = await getTrendingNiches("ID");

  return (
    <main style={{ maxWidth: 1200, margin: "0 auto", padding: 24, fontFamily: "Arial, sans-serif" }}>
      <h1>YouTube Niche Trend Analyzer</h1>
      <p>MVP v1 - trending niche YouTube per negara.</p>

      <section style={{ marginTop: 24 }}>
        <h2>Trending Niches - Indonesia</h2>
        <TrendTable items={data.items || []} />
      </section>
    </main>
  );
}