import os
import re
import json
import argparse
from pathlib import Path
import pdfplumber
import pypdf

BASE_DIR = Path(__file__).resolve().parent.parent
CONTENT_DIR = BASE_DIR / "content"
ASSETS_DIR = BASE_DIR / "assets"
QUESTIONS_IMG_DIR = ASSETS_DIR / "questions"
DATA_DIR = ASSETS_DIR / "data"

WEEK_FILES = {
    1: "week1.pdf",
    2: "week2_assignment.pdf",
    3: "week3.pdf",
    4: "week4.pdf",
    5: "week5.pdf",
    6: "week6.pdf",
    7: "week7.pdf",
    8: "week8.pdf",
    9: "week9.pdf",
    10: "week10.pdf",
    11: "week11.pdf",
}

def extract_week(week_num: int):
    filename = WEEK_FILES.get(week_num)
    if not filename:
        raise ValueError(f"No PDF mapped for week {week_num}")
    
    pdf_path = CONTENT_DIR / filename
    if not pdf_path.exists():
        raise FileNotFoundError(f"PDF not found: {pdf_path}")
    
    week_img_dir = QUESTIONS_IMG_DIR / f"week{week_num}"
    week_img_dir.mkdir(parents=True, exist_ok=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    print(f"--> Extracting Week {week_num} from {filename}...")
    
    pdf_reader = pypdf.PdfReader(str(pdf_path))
    questions = []

    with pdfplumber.open(str(pdf_path)) as plumber_pdf:
        for page_idx, plumber_page in enumerate(plumber_pdf.pages):
            text = plumber_page.extract_text() or ""
            matches = list(re.finditer(
                r'Question\s+(\d+).*?Accepted\s+answer:\s*\(([a-z0-9]+)\)',
                text,
                re.DOTALL | re.IGNORECASE
            ))
            
            pypdf_page = pdf_reader.pages[page_idx]
            page_images_data = list(pypdf_page.images)
            
            plumber_images = sorted(plumber_page.images, key=lambda img: img['top'])
            plumber_names = [img.get('name') for img in plumber_images]
            img_map = {img.name.split('.')[0]: img for img in page_images_data}

            for i, match in enumerate(matches):
                q_num = int(match.group(1))
                ans = match.group(2).strip().lower()
                
                img_filename = f"q{q_num}.png"
                img_path = week_img_dir / img_filename
                
                img_obj = None
                if i < len(plumber_names):
                    p_name = plumber_names[i]
                    img_obj = img_map.get(p_name)
                elif i < len(page_images_data):
                    img_obj = page_images_data[i]
                
                if img_obj:
                    with open(img_path, "wb") as f:
                        f.write(img_obj.data)
                
                questions.append({
                    "id": f"w{week_num}_q{q_num}",
                    "week": week_num,
                    "question_number": q_num,
                    "title": f"Question {q_num}",
                    "image_asset": f"assets/questions/week{week_num}/{img_filename}",
                    "accepted_answer": ans,
                    "accepted_text": f"Accepted answer: ({ans})",
                    "options": ["a", "b", "c", "d"],
                })

    return questions

def main():
    parser = argparse.ArgumentParser(description="Extract questions into Flutter assets")
    parser.add_argument("--week", type=int, default=1, help="Week number to extract")
    parser.add_argument("--all", action="store_true", help="Extract all weeks")
    args = parser.parse_args()

    weeks_to_extract = list(WEEK_FILES.keys()) if args.all else [args.week]
    
    master_file = DATA_DIR / "questions.json"
    all_data = {}
    if master_file.exists():
        try:
            with open(master_file, "r", encoding="utf-8") as f:
                all_data = json.load(f)
        except Exception:
            all_data = {}

    for w in weeks_to_extract:
        qs = extract_week(w)
        all_data[str(w)] = {
            "week": w,
            "title": f"Week {w} Assignment",
            "question_count": len(qs),
            "questions": qs
        }

    with open(master_file, "w", encoding="utf-8") as f:
        json.dump(all_data, f, indent=2)
    
    print(f"\nDone! Extracted {len(weeks_to_extract)} week(s) directly to Flutter assets/.")

if __name__ == "__main__":
    main()
