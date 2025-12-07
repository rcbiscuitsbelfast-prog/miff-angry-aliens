#!/usr/bin/env python3
"""
Migrate yield statements from Godot 3.x to 4.x await syntax
yield(get_tree(), "idle_frame") -> await get_tree().process_frame
yield(get_tree().create_timer(time), "timeout") -> await get_tree().create_timer(time).timeout
yield(object, "signal_name") -> await object.signal_name
"""

import re
import sys
from pathlib import Path

def migrate_yield(content):
    """Replace yield with await"""
    
    # Pattern 1: yield(get_tree(), "idle_frame") or "physics_frame"
    pattern1 = r'yield\(\s*get_tree\(\)\s*,\s*"idle_frame"\s*\)'
    content = re.sub(pattern1, 'await get_tree().process_frame', content)
    
    pattern1b = r'yield\(\s*get_tree\(\)\s*,\s*"physics_frame"\s*\)'
    content = re.sub(pattern1b, 'await get_tree().physics_frame', content)
    
    # Pattern 2: yield(get_tree().create_timer(X), "timeout")
    pattern2 = r'yield\(\s*get_tree\(\)\.create_timer\(([^)]+)\)\s*,\s*"timeout"\s*\)'
    content = re.sub(pattern2, r'await get_tree().create_timer(\1).timeout', content)
    
    # Pattern 3: yield(object, "signal_name") - general case
    pattern3 = r'yield\(\s*([^,]+)\s*,\s*"([^"]+)"\s*\)'
    
    def replace_general(match):
        obj = match.group(1).strip()
        signal = match.group(2)
        return f'await {obj}.{signal}'
    
    content = re.sub(pattern3, replace_general, content)
    
    return content

def process_file(filepath):
    """Process a single GDScript file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        content = migrate_yield(content)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated: {filepath}")
            return True
        else:
            return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}", file=sys.stderr)
        return False

def main():
    project_path = Path('/home/engine/project')
    gd_files = list(project_path.rglob('*.gd'))
    
    updated_count = 0
    for gd_file in gd_files:
        if process_file(gd_file):
            updated_count += 1
    
    print(f"\nMigration complete. Updated {updated_count}/{len(gd_files)} files.")

if __name__ == '__main__':
    main()
