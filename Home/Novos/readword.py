# pip install gtts playsound docx2txt pypdf2
from sys import argv
from os import chdir, system
from os.path import isfile
from docx2txt import process
from PyPDF2 import PdfFileReader
from gtts import gTTS
from playsound import playsound
from time import sleep

if __name__ == '__main__':

    system('cls')

    folder = argv[-2]
    filename = argv[-1]

    print('\nDiretorio... ', end='')
    print(folder)
    print('\nArquivo... ', end='')
    print(filename)

    chdir(folder)

    if isfile(filename):
        pass
    else:
        print('\n\n\nArquivo não encontrado...')
        quit()

    language = 'pt-br'
    language = 'en'

    if filename.find('.docx') > 0:
        
        audio = filename.replace('.docx', '.mp3')
        print('\n\n\nComeçando a ler o arquivo...')
        content = process(filename)

    elif filename.find('.pdf') > 0:
        
        audio = filename.replace('.pdf', '.mp3')
        pdf = open(filename, 'rb')
        content = PdfFileReader(pdf, strict=False)
        pages = [i.extractText() for i in content.pages]
        content = ''
        for item in pages:
            content = content + '\n' + item
            pass
        #print(content)
        pass

    elif filename.find('.txt') > 0:

        audio = filename.replace('.txt', '.mp3')

        with open(filename, mode='r', encoding='utf8') as txt:
            content = txt.read()
            #print(content)

    else:
        print('Extensão não identificada...')
        quit()

    sleep(1)

    print('\n\n\nProcessando o texto em audio...')
    sp = gTTS(
        text=content,
        lang=language
    )

    sleep(1)

    print('\n\n\nComeçando a gravar o arquivo...')
    sp.save(f'{folder}\\{audio}')

    sleep(30)

    print('\n\n\nTocando o arquivo...')
    try:
        playsound(f'{folder}\\{audio}')
    except Exception as err:
        print(f'\n\n\n\tErro : {err}')