import win32api

for l in map(chr, range(97, 123)):
    print(l)
    try:
        serial = win32api.GetVolumeInformation(l + ':/')
        print(serial)
        if serial[1] == 1616992295:
            print('Serial encontrado com sucesso...')
            break
        pass
    except Exception as error:
        print('Erro : ' + str(error))