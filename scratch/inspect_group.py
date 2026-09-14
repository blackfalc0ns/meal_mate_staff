import json

with open('scratch/filter_node_raw.json', 'r', encoding='utf-8') as f:
    d = json.load(f)

def find_node(n, name):
    if n.get('name') == name:
        return n
    for c in n.get('children', []):
        r = find_node(c, name)
        if r:
            return r
    return None

root = list(d['nodes'].values())[0]['document']
group = find_node(root, 'Group 20773')

with open('scratch/group_dump.txt', 'w', encoding='utf-8') as out:
    def dump(n, indent=''):
        bbox = n.get('absoluteBoundingBox', {})
        cr = n.get('cornerRadius')
        strokes = n.get('strokes')
        strokeWeight = n.get('strokeWeight')
        fills = n.get('fills')
        out.write(f'{indent}{n.get("name")} ({n.get("type")}): x={bbox.get("x"):.1f}, y={bbox.get("y"):.1f}, w={bbox.get("width"):.1f}, h={bbox.get("height"):.1f}, cr={cr}\n')
        if fills:
            out.write(f'{indent}  fills: {fills}\n')
        if strokes:
            out.write(f'{indent}  strokes: {strokes}, weight={strokeWeight}\n')
        if 'characters' in n:
            out.write(f'{indent}  TEXT: "{n.get("characters")}" style={n.get("style")}\n')
        for c in n.get('children', []):
            dump(c, indent + '  ')

    if group:
        dump(group)

