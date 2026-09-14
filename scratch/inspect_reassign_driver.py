import json

with open('scratch/reassign_node_raw.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

root = data['nodes']['2259:5608']['document']

with open('scratch/reassign_driver_tree.txt', 'w', encoding='utf-8') as out_f:
    def inspect(node, depth=0):
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

        style = node.get('style', {})
        style_info = ''
        if style:
            fs = style.get('fontSize')
            fw = style.get('fontWeight')
            ff = style.get('fontFamily')
            style_info = f' [Font: {ff} {fw} {fs}px]'

        out_f.write(f'{indent}{name} ({ntype}, {w:.1f}x{h:.1f}){text_str}{fill_str}{stroke_str}{cr_str}{style_info}\n')
        for child in node.get('children', []):
            inspect(child, depth + 1)

    out_f.write('=== ROOT: 10.13 - Assign Replacement Driver (2259:5608) ===\n')
    inspect(root)

print('Done writing scratch/reassign_driver_tree.txt')
