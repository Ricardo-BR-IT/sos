import concurrent.futures
import os
import shutil
import subprocess
import time

APPS = ["mobile_app", "desktop_station", "tv_router", "wearable_app"]
EDITIONS = ["mini", "standard", "server"]
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ARTIFACT_DIR = os.path.join(BASE_DIR, "build_artifacts")
FLUTTER_BIN = os.environ.get("FLUTTER_BIN", r"C:\Users\ricod\flutter\bin")


def _env():
    env = os.environ.copy()
    env["PATH"] = FLUTTER_BIN + os.pathsep + env.get("PATH", "")
    return env


def _run(cmd, cwd):
    return subprocess.run(
        cmd,
        cwd=cwd,
        env=_env(),
        capture_output=True,
        text=True,
        check=True,
    )


def _clear_desktop_ephemeral(app_dir):
    symlink_dir = os.path.join(
        app_dir, "windows", "flutter", "ephemeral", ".plugin_symlinks"
    )
    if os.path.exists(symlink_dir):
        shutil.rmtree(symlink_dir, ignore_errors=True)


def build_app(app, edition):
    start = time.time()
    app_dir = os.path.join(BASE_DIR, "apps", app)
    try:
        if app == "desktop_station":
            _clear_desktop_ephemeral(app_dir)

        _run(["flutter.bat", "pub", "get"], cwd=app_dir)
        if app == "desktop_station":
            _run(
                [
                    "flutter.bat",
                    "build",
                    "windows",
                    "--release",
                    f"--dart-define=EDITION={edition}",
                    "--no-pub",
                ],
                cwd=app_dir,
            )
        else:
            _run(
                [
                    "flutter.bat",
                    "build",
                    "apk",
                    "--release",
                    f"--dart-define=EDITION={edition}",
                    "--no-pub",
                ],
                cwd=app_dir,
            )
    except subprocess.CalledProcessError as exc:
        return False, app, edition, exc.stderr or exc.stdout

    return True, app, edition, f"{time.time() - start:.1f}s"


def _artifact_path(app):
    if app == "desktop_station":
        return os.path.join(
            BASE_DIR,
            "apps",
            app,
            "build",
            "windows",
            "x64",
            "runner",
            "Release",
            "desktop_station.exe",
        )
    return os.path.join(
        BASE_DIR, "apps", app, "build", "app", "outputs", "flutter-apk", "app-release.apk"
    )


def _artifact_name(app, edition):
    if app == "mobile_app":
        return f"mobile-{edition}.apk"
    if app == "tv_router":
        return f"tv-{edition}.apk"
    if app == "wearable_app":
        return f"wear-{edition}.apk"
    return f"desktop-{edition}.exe"


def main():
    os.makedirs(ARTIFACT_DIR, exist_ok=True)
    summary = []

    for edition in EDITIONS:
        print(f"\n=== BUILD EDITION: {edition} ===")
        ed_dir = os.path.join(ARTIFACT_DIR, edition)
        os.makedirs(ed_dir, exist_ok=True)

        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(build_app, app, edition) for app in APPS]
            for future in concurrent.futures.as_completed(futures):
                ok, app, ed, output = future.result()
                summary.append((ok, app, ed, output))
                status = "OK" if ok else "FAIL"
                print(f"[{status}] {app} ({ed}) {output}")

        edition_failures = [s for s in summary if s[2] == edition and not s[0]]
        if edition_failures:
            print(f"Edition {edition} failed.")
            return 1

        for app in APPS:
            src = _artifact_path(app)
            dst = os.path.join(ed_dir, _artifact_name(app, edition))
            if not os.path.exists(src):
                print(f"Artifact missing: {src}")
                return 1
            shutil.copy2(src, dst)
            print(f"Artifact copied: {dst}")

    print("\nAll edition builds succeeded.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
