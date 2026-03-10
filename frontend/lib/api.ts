const API_BASE = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";

export async function getTrendingNiches(country: string) {
  const response = await fetch(`${API_BASE}/api/niches/trending?country=${country}`, {
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error("Failed to fetch trending niches");
  }

  return response.json();
}