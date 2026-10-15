import json

with open('app/data/questions.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for week_str, wdata in data.items():
    for q in wdata['questions']:
        q['image_asset'] = f"assets/questions/week{week_str}/q{q['question_number']}.png"

with open('assets/data/questions.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print("Generated assets/data/questions.json successfully")
