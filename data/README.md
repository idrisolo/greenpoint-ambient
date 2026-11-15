# data/editor.json

Written every morning by the "Greenpoint Ambient AI editor" routine (a scheduled Claude session).
The TV page loads it every 30 minutes and ignores it if `updated` is more than 3 days old.

```json
{
  "updated": "YYYY-MM-DD",
  "headline": { "title": "", "body": "", "meta": "", "day": "YYYY-MM-DD", "timeText": "7:00 PM", "until": "YYYY-MM-DD", "url": "https://..." },
  "picks": [
    { "cat": "holiday|film|art|music|food|city", "title": "", "body": "", "meta": "", "place": "", "boro": "Brooklyn|Manhattan|Queens|the Bronx|Staten Island",
      "day": "YYYY-MM-DD", "time24": "19:00", "timeText": "7:00 PM", "until": "YYYY-MM-DD", "url": "https://..." }
  ],
  "facts": [ { "c": "category", "t": "text", "src": "https://..." } ],
  "countdowns": [ { "date": "YYYY-MM-DD", "title": "", "body": "", "url": "https://..." } ],
  "sources": ["https://..."]
}
```
All fields except `updated` are optional. `day`/`time24`/`timeText` only for dated items; `until` hides an item after that date.
