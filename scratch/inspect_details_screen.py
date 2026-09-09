import json
import os

with open(r'scratch/new_screen_raw.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

nodes = data.get('nodes', {})

def inspect_node(node, depth=0):
    indent = '  ' * depth
    name = node.get('name', '')
    ntype = node.get('type', '')
    chars = node.get('characters', '')
    bbox = node.get('absoluteBoundingBox', {})
    w, h = bbox.get('width', 0), bbox.get('height', 0)
    text_str = f' -> "{chars}"' if chars else ''
    
    # Check fills
    fills = node.get('fills', [])
    fills_info = []
    for fill in fills:
        if fill.get('type') == 'SOLID' and 'color' in fill:
            c = fill['color']
            r, g, b = int(c.get('r', 0)*255), int(c.get('g', 0)*255), int(c.get('b', 0)*255)
            a = fill.get('opacity', c.get('a', 1))
            fills_info.append(f'#{r:02x}{g:02x}{b:02x}({a:.2f})')
        elif fill.get('type') == 'IMAGE':
            fills_info.append('IMAGE')
    fill_str = f' [fills: {", ".join(fills_info)}]' if fills_info else ''
    
    # Corner radius
    cr = node.get('cornerRadius', '')
    cr_str = f' [radius: {cr}]' if cr else ''

    # Strokes
    strokes = node.get('strokes', [])
    strokes_info = []
    for s in strokes:
        if s.get('type') == 'SOLID' and 'color' in s:
            c = s['color']
            r, g, b = int(c.get('r', 0)*255), int(c.get('g', 0)*255), int(c.get('b', 0)*255)
            strokes_info.append(f'#{r:02x}{g:02x}{b:02x}')
    stroke_str = f' [strokes: {", ".join(strokes_info)}]' if strokes_info else ''

    # Layout
    item_spacing = node.get('itemSpacing', '')
    pad = f"pad(T:{node.get('paddingTop',0)},R:{node.get('paddingRight',0)},B:{node.get('paddingBottom',0)},L:{node.get('paddingLeft',0)})" if any(node.get(k,0) for k in ['paddingTop','paddingRight','paddingBottom','paddingLeft']) else ''
    layout_str = f' [{pad} gap:{item_spacing}]' if (pad or item_spacing) else ''

    print(f'{indent}{name} ({ntype}, {w:.1f}x{h:.1f}){text_str}{fill_str}{stroke_str}{cr_str}{layout_str}')
    for child in node.get('children', []):
        inspect_node(child, depth + 1)

with open(r'scratch/details_inspection.txt', 'w', encoding='utf-8') as out_f:
    for k, v in nodes.items():
        doc = v.get('document', {})
        out_f.write(f'=== ROOT NODE: {doc.get("name")} ({k}) ===\n')
        def inspect_node_file(node, depth=0):
            indent = '  ' * depth
            name = node.get('name', '')
            ntype = node.get('type', '')
            chars = node.get('characters', '')
            bbox = node.get('absoluteBoundingBox', {})
            w, h = bbox.get('width', 0), bbox.get('height', 0)
            text_str = f' -> "{chars}"' if chars else ''
            
            fills = node.get('fills', [])
            fills_info = []
            for fill in fills:
                if fill.get('type') == 'SOLID' and 'color' in fill:
                    c = fill['color']
                    r, g, b = int(c.get('r', 0)*255), int(c.get('g', 0)*255), int(c.get('b', 0)*255)
                    a = fill.get('opacity', c.get('a', 1))
                    fills_info.append(f'#{r:02x}{g:02x}{b:02x}({a:.2f})')
                elif fill.get('type') == 'IMAGE':
                    fills_info.append('IMAGE')
            fill_str = f' [fills: {", ".join(fills_info)}]' if fills_info else ''
            
            cr = node.get('cornerRadius', '')
            cr_str = f' [radius: {cr}]' if cr else ''

            strokes = node.get('strokes', [])
            strokes_info = []
            for s in strokes:
                if s.get('type') == 'SOLID' and 'color' in s:
                    c = s['color']
                    r, g, b = int(c.get('r', 0)*255), int(c.get('g', 0)*255), int(c.get('b', 0)*255)
                    strokes_info.append(f'#{r:02x}{g:02x}{b:02x}')
            stroke_str = f' [strokes: {", ".join(strokes_info)}]' if strokes_info else ''

            item_spacing = node.get('itemSpacing', '')
            pad = f"pad(T:{node.get('paddingTop',0)},R:{node.get('paddingRight',0)},B:{node.get('paddingBottom',0)},L:{node.get('paddingLeft',0)})" if any(node.get(k,0) for k in ['paddingTop','paddingRight','paddingBottom','paddingLeft']) else ''
            layout_str = f' [{pad} gap:{item_spacing}]' if (pad or item_spacing) else ''

            out_f.write(f'{indent}{name} ({ntype}, {w:.1f}x{h:.1f}){text_str}{fill_str}{stroke_str}{cr_str}{layout_str}\n')
            for child in node.get('children', []):
                inspect_node_file(child, depth + 1)
        inspect_node_file(doc)

