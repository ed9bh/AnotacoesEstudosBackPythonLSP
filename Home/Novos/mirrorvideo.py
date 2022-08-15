from moviepy.editor import VideoFileClip, vfx
from sys import argv

if __name__ == '__main__':

    file = argv[-1]

    clip = VideoFileClip(file)

    reversed = clip.fx(vfx.mirror_x)

    new_name = file.replace('.mp4', '') + '-mirror.mp4'

    reversed.write_videofile(new_name)