#!/bin/bash
# Godot 3.x to 4.x migration script for common syntax changes

find . -name "*.gd" -type f | while read file; do
    echo "Processing: $file"
    
    # Create backup
    cp "$file" "$file.bak"
    
    # Replace onready with @onready
    sed -i 's/^onready var/@onready var/g' "$file"
    sed -i 's/^\tonready var/\t@onready var/g' "$file"
    sed -i 's/^    onready var/    @onready var/g' "$file"
    
    # Replace export with @export (simple cases)
    sed -i 's/^export var/@export var/g' "$file"
    sed -i 's/^\texport var/\t@export var/g' "$file"
    sed -i 's/^    export var/    @export var/g' "$file"
    
    # Replace export(Type) with @export var name: Type
    sed -i 's/^export(int) var \([a-zA-Z_][a-zA-Z0-9_]*\)/@export var \1: int/g' "$file"
    sed -i 's/^export(float) var \([a-zA-Z_][a-zA-Z0-9_]*\)/@export var \1: float/g' "$file"
    sed -i 's/^export(bool) var \([a-zA-Z_][a-zA-Z0-9_]*\)/@export var \1: bool/g' "$file"
    sed -i 's/^export(String) var \([a-zA-Z_][a-zA-Z0-9_]*\)/@export var \1: String/g' "$file"
    
    # Replace Texture with Texture2D
    sed -i 's/: Texture\([^2D]\|$\)/: Texture2D\1/g' "$file"
    sed -i 's/-> Texture\([^2D]\|$\)/-> Texture2D\1/g' "$file"
    sed -i 's/(Texture)/(Texture2D)/g' "$file"
    
    # Replace .get_size() with .get_width() or .get_height()
    # This is more complex and context-dependent, so we'll skip for now
    
    # Replace KinematicBody2D with CharacterBody2D
    sed -i 's/extends KinematicBody2D/extends CharacterBody2D/g' "$file"
    
    # Replace instance() with instantiate()
    sed -i 's/\.instance()/\.instantiate()/g' "$file"
    
    # Replace rand_range with randf_range
    sed -i 's/rand_range(/randf_range(/g' "$file"
    
    # Replace emit_signal with signal.emit()
    # This is complex and context-dependent, skipping for manual review
    
    echo "Done: $file"
done

echo "Migration complete. Backup files created with .bak extension"
