from sys import argv
from os import chdir
from math import ceil
# from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip
from moviepy.editor import VideoFileClip
from time import sleep

def clip(orignal_name, start, end):
    from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip
    new_name = original_name.replace('.mp4', '') + f'-Clip_{start}-{end}.mp4'
    ffmpeg_extract_subclip(orignal_name, start, end, targetname=new_name)
    del(ffmpeg_extract_subclip)
    pass

if __name__ == '__main__':
    original_name = argv[1]
    flag = argv[2]
    fator = 60.000000

    print('\n\n\n' + original_name + '\n\n\n')
    print(flag + '\n\n\n')

    if flag.find(',') > 0:
        start, end = flag.split(',')
        clip(original_name, int(start), int(end))
    elif flag == 'total':
        total_time = VideoFileClip(original_name).duration
        print(total_time)
        start, end = 0.000000, fator
        total_clips = int(ceil(total_time / fator))
        for _ in range(total_clips):
            if end > total_time:
                end = total_time
            clip(original_name, start, end)
            start, end = end, end + fator
            sleep(3)
        pass