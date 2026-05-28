# University Data Flow

The app reads universities from Firestore first:

```text
universities/{universityId}
```

If Firestore has no documents or the read fails, the app falls back to:

```text
lib/data/university_data.dart
```

## Firestore Fields

Each `universities` document should use this shape:

```json
{
  "name": "Royal University of Phnom Penh",
  "shortName": "RUPP",
  "location": "Khan Toul Kork, Phnom Penh",
  "address": "Russian Federation Blvd, Khan Toul Kork, Phnom Penh, Cambodia",
  "rating": 4.5,
  "tuition": "$400 - $800",
  "curriculum": "Cambodian",
  "type": "Public",
  "imageUrl": "https://example.com/campus.jpg",
  "mapImageUrl": "https://example.com/map-preview.jpg",
  "majors": ["IT Engineering", "Mathematics", "Education"],
  "about": "Description shown on the university detail page.",
  "mapUrl": "https://www.google.com/maps/search/?api=1&query=Royal%20University%20of%20Phnom%20Penh",
  "admissionUrl": "https://www.rupp.edu.kh/"
}
```

Field types:

- `rating`: number
- `majors`: array of strings
- every other field: string

## Seed File

The Firestore-ready seed data lives at:

```text
firebase_seed/universities.json
```

Create one document per top-level key:

- `aupp`
- `rupp`
- `puc`
- `num`
- `paragon`

## Manual Firebase Console Setup

1. Open Firebase Console.
2. Go to Firestore Database.
3. Create collection `universities`.
4. Create each document using the IDs from `firebase_seed/universities.json`.
5. Add the fields exactly as shown in the seed file.
6. Restart the app. If Firestore reads work, the app will show Firebase data instead of fallback data.

## Hardcoded Backup

Keep `lib/data/university_data.dart` updated with the same core data as Firestore. This gives the app useful content if Firestore is empty, offline, or blocked by rules.
