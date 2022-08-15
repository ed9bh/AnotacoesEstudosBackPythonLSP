echo off

cls

set pyscripts="C:\Users\ericd\Downloads\_PyScripts"
set video_name="C:\Users\ericd\Downloads\Videos\.mp4"
set flag="total"

cd %pyscripts%

py clipvideo.py %video_name% %flag%

pause