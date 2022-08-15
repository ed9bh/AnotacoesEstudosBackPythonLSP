from sys import argv
from os import chdir
from math import ceil
from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip
from moviepy.editor import VideoFileClip

def clip(orignal_name, start, end):
    #new_name = (f'Clip_{start}-{end}_{orignal_name}')
    new_name = original_name.replace('.mp4', '') + f'-Clip_{start}-{end}.mp4'
    ffmpeg_extract_subclip(orignal_name, start, end, targetname=new_name)
    pass

if __name__ == '__main__':
    original_name = argv[1]
    flag = argv[2]

    print('\n\n\n' + original_name + '\n\n\n')
    print(flag + '\n\n\n')

    if flag.find(',') > 0:
        start, end = flag.split(',')
        clip(original_name, int(start), int(end))
    elif flag == 'total':
        total_time = VideoFileClip(original_name).duration
        print(total_time)
        start, end = 0, 60
        total_clips = int(ceil(total_time / 60))
        for _ in range(total_clips):
            if end > total_time:
                end = total_time
            clip(original_name, start, end)
            start, end = end, end + 60
        pass