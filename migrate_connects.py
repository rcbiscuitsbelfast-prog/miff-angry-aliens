#!/usr/bin/env python3
"""
Migrate .connect() calls from Godot 3.x to 4.x format
object.connect("signal_name", target, "method_name", [args]) -> object.signal_name.connect(target.method_name.bind(args))
object.connect("signal_name", target, "method_name") -> object.signal_name.connect(target.method_name)
"""

import re
import sys
from pathlib import Path

def migrate_connect_calls(content):
    """Replace old .connect() calls with new callable syntax"""
    
    # Pattern 1: .connect("signal", target, "method", [args])
    pattern1 = r'\.connect\(\s*"([^"]+)"\s*,\s*(\w+)\s*,\s*"([^"]+)"\s*,\s*\[([^\]]*)\]\s*\)'
    
    def replace_with_args(match):
        signal_name = match.group(1)
        target = match.group(2)
        method = match.group(3)
        args = match.group(4).strip()
        
        return f'.{signal_name}.connect({target}.{method}.bind({args}))'
    
    content = re.sub(pattern1, replace_with_args, content)
    
    # Pattern 2: .connect("signal", target, "method") - without args
    pattern2 = r'\.connect\(\s*"([^"]+)"\s*,\s*(\w+)\s*,\s*"([^"]+)"\s*\)'
    
    def replace_no_args(match):
        signal_name = match.group(1)
        target = match.group(2)
        method = match.group(3)
        
        return f'.{signal_name}.connect({target}.{method})'
    
    content = re.sub(pattern2, replace_no_args, content)
    
    return content

def process_file(filepath):
    """Process a single GDScript file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        content = migrate_connect_calls(content)
        
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
