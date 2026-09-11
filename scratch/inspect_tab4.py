import json

with open('scratch/node_2279_15269_raw.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

node = data['nodes']['2279:15269']['document']

with open('scratch/tab4_info.txt', 'w', encoding='utf-8') as out:
    def print_tree(n, depth=0):
        indent = '  ' * depth
        name = n.get('name', '')
        ntype = n.get('type', '')
        chars = n.get('characters', '')
        text_info = f' TEXT: "{chars}"' if chars else ''
        bbox = n.get('absoluteBoundingBox', {})
        w, h = bbox.get('width', 0), bbox.get('height', 0)
        out.write(f'{indent}{name} ({ntype}, {w:.1f}x{h:.1f}){text_info}\n')
        for c in n.get('children', []):
            print_tree(c, depth + 1)

    print_tree(node)
print("Done writing tab4_info.txt")
