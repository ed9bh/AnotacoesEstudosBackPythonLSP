echo off

cls

set pyscripts="C:\Users\ericd\Downloads\_PyScripts"
set video_name="C:\Users\ericd\Downloads\Videos\Crazy Japanese Prank Floor Dissapears.mp4"
set flag="0,40"

cd %pyscripts%

py clipvideo.py %video_name% %flag%

pause