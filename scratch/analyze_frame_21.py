import json

with open('scratch/frame_21.json', encoding='utf-8') as f:
    d = json.load(f)

with open('scratch/tabs_summary.txt', 'w', encoding='utf-8') as out:
    for c in d.get('children', []):
        out.write(f"Group: {c.get('name')} {c.get('absoluteBoundingBox')}\n")
        for sub in c.get('children', []):
            out.write(f"  Sub: {sub.get('name')} {sub.get('type')} {sub.get('absoluteBoundingBox')} cr={sub.get('cornerRadius')}\n")
            out.write(f"    fills: {sub.get('fills')}\n")
            out.write(f"    strokes: {sub.get('strokes')}\n")
            for ssub in sub.get('children', []):
                out.write(f"    Inner: {ssub.get('name')} {ssub.get('type')} {ssub.get('absoluteBoundingBox')} cr={ssub.get('cornerRadius')}\n")
                out.write(f"      fills: {ssub.get('fills')}\n")
                for sssub in ssub.get('children', []):
                    out.write(f"      Inner3: {sssub.get('name')} {sssub.get('type')} {sssub.get('absoluteBoundingBox')}\n")
                    out.write(f"        fills: {sssub.get('fills')}\n")

print("Done writing tabs_summary.txt")
