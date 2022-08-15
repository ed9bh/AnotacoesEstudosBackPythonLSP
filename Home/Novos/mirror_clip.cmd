echo off

cls

set pyscripts="C:\Users\ericd\Downloads\_PyScripts"
set video_name="C:\Users\ericd\Downloads\Videos\.mp4"

cd %pyscripts%

py mirrorvideo.py %video_name%

pause