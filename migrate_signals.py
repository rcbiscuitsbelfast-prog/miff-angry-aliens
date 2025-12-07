#!/usr/bin/env python3
"""
Migrate emit_signal calls from Godot 3.x to 4.x format
emit_signal("signal_name", arg1, arg2) -> signal_name.emit(arg1, arg2)
"""

import re
import sys
from pathlib import Path

def migrate_emit_signal(content):
    """Replace emit_signal calls with new signal.emit() syntax"""
    
    # Pattern to match emit_signal("signal_name", args...)
    # Captures: signal name and arguments
    pattern = r'emit_signal\(\s*"([^"]+)"(.*?)\)'
    
    def replace_fn(match):
        signal_name = match.group(1)
        args = match.group(2)
        # Remove leading comma and space from args if present
        args = args.strip()
        if args.startswith(','):
            args = args[1:].strip()
        
        if args:
            return f'{signal_name}.emit({args})'
        else:
            return f'{signal_name}.emit()'
    
    return re.sub(pattern, replace_fn, content)

def migrate_connect(content):
    """Replace .connect() calls with new callable syntax"""
    
    # Pattern: .connect("signal_name", object, "method_name")
    # This is more complex and context-dependent, so we'll be conservative
    pattern = r'\.connect\(\s*"([^"]+)"\s*,\s*(\w+)\s*,\s*"([^"]+)"\s*\)'
    
    def replace_fn(match):
        signal_name = match.group(1)
        object_ref = match.group(2)
        method_name = match.group(3)
        return f'.{signal_name}.connect({object_ref}.{method_name})'
    
    return re.sub(pattern, replace_fn, content)

def process_file(filepath):
    """Process a single GDScript file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        content = migrate_emit_signal(content)
        content = migrate_connect(content)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated: {filepath}")
            return True
        else:
            print(f"No changes: {filepath}")
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
