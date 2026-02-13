
import shutil
import sys
import os

def zip_dir(src, dst):
    print(f"Zipping {src} to {dst}...")
    try:
        shutil.make_archive(dst.replace('.zip', ''), 'zip', src)
        print(f"Success: {dst}")
    except Exception as e:
        print(f"Error zipping {src}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python zip_helper.py <src_dir> <dst_zip>")
        sys.exit(1)
    
    src = sys.argv[1]
    dst = sys.argv[2]
    zip_dir(src, dst)
