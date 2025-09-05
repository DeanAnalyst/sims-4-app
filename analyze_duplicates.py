#!/usr/bin/env python3
"""
Script to analyze and remove duplicates from Sims 4 name generator JSON files.
"""

import json
import os
from pathlib import Path
from collections import Counter

def analyze_name_file(file_path):
    """Analyze a single name file for duplicates."""
    print(f"\n=== Analyzing {os.path.basename(file_path)} ===")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Check structure
        if 'firstNames' not in data or 'lastNames' not in data:
            print(f"[ERROR] Invalid structure in {file_path}")
            return None
        
        # Analyze first names
        first_names = data['firstNames']
        first_name_counts = Counter(first_names)
        first_duplicates = {name: count for name, count in first_name_counts.items() if count > 1}
        
        # Analyze last names  
        last_names = data['lastNames']
        last_name_counts = Counter(last_names)
        last_duplicates = {name: count for name, count in last_name_counts.items() if count > 1}
        
        print(f"Region: {data.get('region', 'unknown')}")
        print(f"Gender: {data.get('gender', 'unknown')}")
        print(f"Total first names: {len(first_names)} (unique: {len(first_name_counts)})")
        print(f"Total last names: {len(last_names)} (unique: {len(last_name_counts)})")
        
        if first_duplicates:
            print(f"[ERROR] First name duplicates found: {len(first_duplicates)} unique duplicated names")
        else:
            print("[OK] No first name duplicates")
            
        if last_duplicates:
            print(f"[ERROR] Last name duplicates found: {len(last_duplicates)} unique duplicated names")
        else:
            print("[OK] No last name duplicates")
            
        return {
            'file_path': file_path,
            'region': data.get('region'),
            'gender': data.get('gender'),
            'first_names_total': len(first_names),
            'first_names_unique': len(first_name_counts),
            'last_names_total': len(last_names),
            'last_names_unique': len(last_name_counts),
            'first_duplicates': first_duplicates,
            'last_duplicates': last_duplicates
        }
    
    except Exception as e:
        print(f"[ERROR] Error processing {file_path}: {str(e)}")
        return None

def remove_duplicates_from_file(file_path, backup=True):
    """Remove duplicates from a name file while preserving order."""
    print(f"\n=== Cleaning duplicates from {os.path.basename(file_path)} ===")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Backup original file
        if backup:
            backup_path = str(file_path).replace('.json', '_backup.json')
            with open(backup_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"[OK] Backup created: {os.path.basename(backup_path)}")
        
        # Remove duplicates while preserving order
        original_first = len(data['firstNames'])
        original_last = len(data['lastNames'])
        
        # Use dict.fromkeys() to preserve order while removing duplicates
        data['firstNames'] = list(dict.fromkeys(data['firstNames']))
        data['lastNames'] = list(dict.fromkeys(data['lastNames']))
        
        cleaned_first = len(data['firstNames'])
        cleaned_last = len(data['lastNames'])
        
        print(f"First names: {original_first} -> {cleaned_first} (removed {original_first - cleaned_first})")
        print(f"Last names: {original_last} -> {cleaned_last} (removed {original_last - cleaned_last})")
        
        # Save cleaned file
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"[OK] File cleaned and saved")
        
        return {
            'first_removed': original_first - cleaned_first,
            'last_removed': original_last - cleaned_last,
            'first_remaining': cleaned_first,
            'last_remaining': cleaned_last
        }
        
    except Exception as e:
        print(f"[ERROR] Error cleaning {file_path}: {str(e)}")
        return None

def main():
    # Path to name files
    names_dir = Path("C:/Users/Dean/Dev/sims 4 app/sims4_name_generator/assets/data/names")
    
    if not names_dir.exists():
        print(f"[ERROR] Directory not found: {names_dir}")
        return
    
    # Find all JSON files
    json_files = list(names_dir.glob("*.json"))
    
    if not json_files:
        print(f"[ERROR] No JSON files found in {names_dir}")
        return
    
    print(f"Found {len(json_files)} name files to analyze")
    
    # Analyze all files first
    analysis_results = []
    for file_path in sorted(json_files):
        result = analyze_name_file(file_path)
        if result:
            analysis_results.append(result)
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY OF DUPLICATES")
    print("="*60)
    
    total_first_duplicates = 0
    total_last_duplicates = 0
    files_with_issues = 0
    
    for result in analysis_results:
        if result['first_duplicates'] or result['last_duplicates']:
            files_with_issues += 1
            first_dupe_count = sum(result['first_duplicates'].values()) - len(result['first_duplicates'])
            last_dupe_count = sum(result['last_duplicates'].values()) - len(result['last_duplicates'])
            total_first_duplicates += first_dupe_count
            total_last_duplicates += last_dupe_count
            
            print(f"[ERROR] {result['region']}_{result['gender']}: {first_dupe_count + last_dupe_count} duplicates")
    
    if files_with_issues == 0:
        print("[OK] No duplicate names found in any files!")
        return
    
    print(f"\nFiles with duplicates: {files_with_issues}/{len(analysis_results)}")
    print(f"Total duplicate first names to remove: {total_first_duplicates}")
    print(f"Total duplicate last names to remove: {total_last_duplicates}")
    
    # Auto-proceed with cleaning
    print("\nProceeding with duplicate removal automatically...")
    
    if True:
        print("\n" + "="*60)
        print("CLEANING DUPLICATES")
        print("="*60)
        
        total_removed = 0
        for file_path in sorted(json_files):
            result = remove_duplicates_from_file(file_path)
            if result:
                total_removed += result['first_removed'] + result['last_removed']
        
        print(f"\n[OK] Cleaning complete! Removed {total_removed} duplicate names total.")
        print("[INFO] Re-run the script to verify all duplicates were removed.")
    else:
        print("[INFO] Duplicate removal cancelled.")

if __name__ == "__main__":
    main()