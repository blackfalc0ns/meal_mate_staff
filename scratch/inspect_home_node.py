import json

with open('scratch/node_2922_6775_raw.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

root = data['nodes']['2922:6775']['document']

import sys
import io

out_file = open('scratch/home_node_tree.txt', 'w', encoding='utf-8')

def print_out(s):
    out_file.write(s + '\n')

def analyze_node(node, depth=0):
    indent = '  ' * depth
    name = node.get('name', '')
    ntype = node.get('type', '')
    bbox = node.get('absoluteBoundingBox', {})
    w = bbox.get('width', 0)
    h = bbox.get('height', 0)
    text = node.get('characters', '')
    text_info = f' TEXT: "{text}"' if text else ''
    
    # Check fills
    fills = node.get('fills', [])
    fill_info = ''
    if fills:
        for fill in fills:
            if fill.get('visible', True) and fill.get('type') == 'SOLID':
                c = fill.get('color', {})
                r, g, b = int(c.get('r', 0)*255), int(c.get('g', 0)*255), int(c.get('b', 0)*255)
                a = fill.get('opacity', c.get('a', 1))
                fill_info += f' #{r:02X}{g:02X}{b:02X}({a:.2f})'
                
    style = node.get('style', {})
    style_info = ''
    if style:
        fs = style.get('fontSize')
        fw = style.get('fontWeight')
        ff = style.get('fontFamily')
        style_info = f' [Font: {ff} {fw} {fs}px]'
        
    print_out(f'{indent}{name} ({ntype}, {w:.1f}x{h:.1f}){fill_info}{style_info}{text_info}')
    
    for child in node.get('children', []):
        analyze_node(child, depth + 1)

print_out("=== TREE INSPECTION ===")
analyze_node(root)
out_file.close()
print("Done writing scratch/home_node_tree.txt")
