# CareLoop Clinics — No-Show Guard

**Public GitHub repository:** `https://github.com/kamblechaitanya-sudo/capstone-careloop-clinics.git`

## Project overview

CareLoop Clinics wants to identify appointments at higher risk of being missed, understand why patients miss them, and give the front desk a useful call list. This project cleans the appointment data, analyzes no-show patterns, builds and evaluates prediction models, and uses Gemini to structure a small sample of follow-up notes.

## Results summary

Part 1: Cleaned 990 appointments; 218 were no-shows (22.0%).

Part 2: The 31+ day lead-time band had 26 no-shows among 43 appointments (60.5%).

Part 3: Logistic regression had the best training cross-validation AUC (0.774); the selected threshold was 0.35, and test AUC was 0.789.

Part 4: Of the 10 notes, 7 were valid, 2 invalid, and 1 skipped as blank; both notes classified as forgot/no-reminder were linked to `reminder_sent = No`.

## Recommendation

On the evening before each appointment, rank bookings by the logistic regression risk score and call the highest-risk bookings first, using 0.35 as the flagging threshold. Logistic regression was selected because it had the highest training cross-validation AUC (0.774); its test AUC was 0.789, and the 0.35 threshold improves the chance of catching more likely no-shows. The 31+ day lead-time band is also worth prioritizing for review: 26 of its 43 appointments were no-shows (60.5%). Check reminder delivery when calling: both of the two notes classified as forgot/no-reminder were linked to `reminder_sent = No`. An extra call costs about a minute, while a missed warning can leave a doctor’s slot empty. The 10 analyzed notes are only an illustration and do not establish clinic-wide reasons for missed appointments.

## Limitations

1. The 10 follow-up notes are a small sample and cannot establish the reasons for no-shows across all clinics.
2. The random train/test split does not represent training on the past and predicting future appointments.
3. The data are observational, so relationships such as reminders and no-shows do not prove that one caused the other.

## Repository contents

- `01_ingest_clean.ipynb` — Tasks 1.1–1.6
- `rejected_rows.json`
- `appointments_clean.csv`
- `clinics_enriched.csv`
- `load_data.sql`
- `02_queries.sql` — Part 2 queries
- `03_model.ipynb` — Part 3 modeling
- `test_risk_scores.csv`
- `04_genai.ipynb` — Part 4 note analysis
- `notes_analysed.csv`
- `data/` — original project datasets

## Reproducing the work

Run the notebooks in order. Run `load_data.sql` in MySQL Workbench before running the Part 2 queries. The Gemini notebook uses an API key; keep the key out of the notebook and repository.
