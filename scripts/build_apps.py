
import os
import subprocess
import time
import concurrent.futures
import shutil

# Configuration
APPS = ["mobile_app", "desktop_station", "tv_router", "wearable_app"]
EDITIONS = ["mini", "standard", "server"]
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DEPLOY_STAGE = os.path.join(BASE_DIR, "deploy_stage")

def build_app(app, edition):
    start_time = time.time()
    print(f"[{app.upper()}] Building edition: {edition}...")
    
    app_dir = os.path.join(BASE_DIR, "apps", app)
    
    flutter_cmd = "flutter.bat" if os.name == 'nt' else "flutter"
    
    # 1. Run PUB GET
    print(f"[{app.upper()}] Running pub get...")
    try:
        subprocess.run(
            [flutter_cmd, "pub", "get"],
            cwd=app_dir,
            check=True,
            capture_output=True
        )
    except subprocess.CalledProcessError as e:
        print(f"[{app.upper()}] ❌ Pub Get Failed: {e}")
        return (False, app, edition, "Pub Get Failed")

    # 2. Construct Build Command
    cmd = [flutter_cmd, "build"]
    if app == "desktop_station":
        cmd.append("windows")
    else:
        cmd.append("apk")
    
    cmd.extend(["--release", f"--dart-define=EDITION={edition}", "--no-pub"])
    
    try:
        # Run build
        result = subprocess.run(
            cmd,
            cwd=app_dir,
            capture_output=True,
            text=True,
            check=True
        )
        duration = time.time() - start_time
        print(f"[{app.upper()}] Success ({edition}) in {duration:.1f}s")
        return (True, app, edition, result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"[{app.upper()}] Failed ({edition}): {e.stderr}")
        return (False, app, edition, e.stderr)

def main():
    print("Starting Parallel Build via Python...")
    print(f"Apps: {APPS}")
    print(f"Editions: {EDITIONS}")
    
    os.makedirs(DEPLOY_STAGE, exist_ok=True)
    
    results = []
    
    # Use ThreadPoolExecutor for parallelism
    # We have 4 apps * 3 editions = 12 builds.
    # Max workers = 4 (to avoid killing the machine)
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        futures = []
        for edition in EDITIONS:
            # Create edition folder in deploy_stage
            ee_dir = os.path.join(DEPLOY_STAGE, edition)
            os.makedirs(ee_dir, exist_ok=True)
            
            for app in APPS:
                futures.append(executor.submit(build_app, app, edition))
        
        for future in concurrent.futures.as_completed(futures):
            success, app, edition, output = future.result()
            results.append((success, app, edition))
            
            if success:
                # Copy artifact
                src = ""
                dest_name = ""
                if app == "desktop_station":
                    src = os.path.join(BASE_DIR, "apps", app, "build", "windows", "x64", "runner", "Release", "desktop_station.exe")
                    dest_name = f"desktop-{edition}.exe"
                elif app == "mobile_app":
                    src = os.path.join(BASE_DIR, "apps", app, "build", "app", "outputs", "flutter-apk", "app-release.apk")
                    dest_name = f"mobile-{edition}.apk"
                elif app == "tv_router":
                    src = os.path.join(BASE_DIR, "apps", app, "build", "app", "outputs", "flutter-apk", "app-release.apk")
                    dest_name = f"tv-{edition}.apk"
                elif app == "wearable_app":
                    src = os.path.join(BASE_DIR, "apps", app, "build", "app", "outputs", "flutter-apk", "app-release.apk")
                    dest_name = f"wear-{edition}.apk"
                
                dest = os.path.join(DEPLOY_STAGE, edition, dest_name)
                if os.path.exists(src):
                    shutil.copy2(src, dest)
                    print(f"Artifact copied: {dest}")
                else:
                    print(f"Artifact not found: {src}")

    # Summary
    print("\n--- Build Summary ---")
    failures = 0
    for success, app, edition in results:
        status = "SUCCESS" if success else "FAILED"
        print(f"{status} {app} ({edition})")
        if not success:
            failures += 1
            
    if failures > 0:
        print(f"\n{failures} builds failed.")
        exit(1)
    else:
        print("\nAll builds succeeded!")
        exit(0)

if __name__ == "__main__":
    main()
