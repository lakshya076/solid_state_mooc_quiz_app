import json
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
data_file = BASE_DIR / "assets" / "data" / "questions.json"

with open(data_file, "r", encoding="utf-8") as f:
    data = json.load(f)

total_questions = 0
all_valid = True

for week_str in sorted(data.keys(), key=lambda x: int(x)):
    wdata = data[week_str]
    qs = wdata["questions"]
    total_questions += len(qs)
    
    missing_images = []
    for q in qs:
        img_path = BASE_DIR / q["image_asset"]
        if not img_path.exists():
            missing_images.append(q["image_asset"])
            all_valid = False
            
    q_start = qs[0]["question_number"]
    q_end = qs[-1]["question_number"]
    print(f"Week {week_str:>2}: {len(qs):>2} questions (Q{q_start:>3} - Q{q_end:>3}) | Images missing: {len(missing_images)}")

print("-" * 50)
print(f"TOTAL QUESTIONS: {total_questions}")
print(f"ALL ASSETS VALID: {all_valid}")
