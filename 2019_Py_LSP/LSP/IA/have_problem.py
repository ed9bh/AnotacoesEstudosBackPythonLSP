def Problem_Solver():
    try:
        import os, re, sys, shutil
        Module_List = [m.__name__ for m in sys.modules.values()]
        for module in Module_List:
            if re.match(r'win32com\.gen_py\..+', module):
                del sys.modules[module]
                pass
            pass
        shutil.rmtree(os.path.join(os.environ.get('LOCALAPPDATA'), 'Temp', 'gen_py'))
        print('Reinicie o AutoCAD e Python para continuar...')
        pass
    except Exception as er:
        print(f'Erro : {er}')
        pass
    pass