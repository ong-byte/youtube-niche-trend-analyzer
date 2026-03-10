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

export default function TrendTable({ items }: { items: Item[] }) {
  return (
    <div style={{ overflowX: "auto", border: "1px solid #ddd", borderRadius: 12, padding: 12 }}>
      <table style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr>
            <th align="left">Niche</th>
            <th align="left">Category</th>
            <th align="right">Views</th>
            <th align="right">Uploads</th>
            <th align="right">Channels</th>
            <th align="right">Trend</th>
            <th align="right">Competition</th>
            <th align="right">Opportunity</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={`${item.country_code}-${item.niche_id}`}>
              <td>{item.niche_name}</td>
              <td>{item.category}</td>
              <td align="right">{item.total_views.toLocaleString()}</td>
              <td align="right">{item.total_uploads.toLocaleString()}</td>
              <td align="right">{item.active_channels.toLocaleString()}</td>
              <td align="right">{item.trend_score}</td>
              <td align="right">{item.competition_score}</td>
              <td align="right">{item.opportunity_score}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}