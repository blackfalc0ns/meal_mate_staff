import json

with open('scratch/filter_node_raw.json', 'r', encoding='utf-8') as f:
    d = json.load(f)

root = list(d['nodes'].values())[0]['document']

def find_overlay(node):
    if 'Driver Filters' in node.get('name', ''):
        return node
    for c in node.get('children', []):
        res = find_overlay(c)
        if res:
            return res
    return None

overlay = find_overlay(root)
with open('scratch/filter_tree.txt', 'w', encoding='utf-8') as out_f:
    if overlay:
        def print_tree(node, depth=0):
            indent = '  ' * depth
            name = node.get('name', '')
            chars = node.get('characters', '')
            text = f' -> "{chars}"' if chars else ''
            bbox = node.get('absoluteBoundingBox', {})
            w, h = bbox.get('width', 0), bbox.get('height', 0)
            fills = node.get('fills', [])
            f_list = []
            for f in fills:
                if f.get('type') == 'SOLID' and 'color' in f:
                    c = f['color']
                    r, g, b = int(c.get('r', 0)*255), int(c.get('g', 0)*255), int(c.get('b', 0)*255)
                    f_list.append(f'#{r:02x}{g:02x}{b:02x}')
            f_str = f' [fills: {", ".join(f_list)}]' if f_list else ''
            out_f.write(f'{indent}{name} ({node.get("type")}, {w:.1f}x{h:.1f}){text}{f_str}\n')
            for ch in node.get('children', []):
                print_tree(ch, depth + 1)
        print_tree(overlay)
        print('Wrote scratch/filter_tree.txt')
    else:
        out_f.write('Overlay not found!\n')
        print('Overlay not found')
