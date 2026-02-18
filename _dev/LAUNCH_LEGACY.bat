@echo off
if exist "apps\legacy_terminal\index.html" (
    start "" "apps\legacy_terminal\index.html"
) else (
    echo Legacy terminal not found.
)
exit
