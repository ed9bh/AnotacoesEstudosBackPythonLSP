# %%
from win32com.client import Dispatch, gencache, VARIANT
from winreg import OpenKey, EnumValue, HKEY_CLASSES_ROOT
from pythoncom import VT_ARRAY, VT_R8
# %%
class Civil3D():
    def __init__(self):
        self.Started = None
        self.app_id = None
        self.ac3d = None
        self.doc = None
        self.mspace = None
        pass

    @property
    def look_for_acad_key(self):
        key_base = 'AutoCAD.Application\\CLSID'
        with OpenKey(HKEY_CLASSES_ROOT, key_base) as key:
            try:
                value = EnumValue(key, 0)[1]
                return value
            except Exception as er:
                print(f'Certifique-se do AutoCAD estar instalado : {er}')
                return 'Erro Fatal...'
    
    @property
    def look_for_ac3d_key(self):
        x, y = 0, 0
        now_version = False

        while now_version == False:

            y += 1

            if x > 20:
                break
            elif y > 9:
                y = 0
                x += 1
                pass

            try:
                version = f'AeccXUiLand.AeccApplication.{x}.{y}'
                OpenKey(HKEY_CLASSES_ROOT, version)
                now_version = True
                pass
            except:
                pass
            pass

        return version

    def Start(self):
        if self.Started is None:
            app_id = self.look_for_acad_key
            app_id_ac3d = self.look_for_ac3d_key
            try:
                app_name = gencache.GetModuleForProgID(app_id)
                app_ensure = gencache.EnsureDispatch(app_id)
                app_object = Dispatch(app_ensure)
                app_object = app_object.GetInterfaceObject(app_id_ac3d)
                self.ac3d = app_object
                self.Started = True
                print(f'Codigo APP : {app_name}\nFeito em 2020 por Eric Drumond')
                return app_object
            except Exception as error:
                print(f'Erro : {error}')
                pass
            pass
        pass

    @property
    def Config(self):
        self.doc = self.ac3d.ActiveDocument
        self.mspace = self.doc.ModelSpace
        self.doc.Utility.Prompt('\n\n\nACAD Abduzido (Python no Controle)... By: Eric Drumond/2020...\n\n\n')
        pass

    def POINT(self, x:float=0, y:float=0, z:float=0):
        return VARIANT(VT_ARRAY | VT_R8, (float(x), float(y), float(z)))

    def POINT_LIST(self, coord_list:list):
        coord_list = [float(n) for n in coord_list]
        return VARIANT(VT_ARRAY | VT_R8, coord_list)