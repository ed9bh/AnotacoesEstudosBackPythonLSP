#%%
from win32com.client import CastTo
#%%
class Command():
    def __init__(self, acad_translator):
        if 'acad' in dir(acad_translator):
            acad = acad_translator.acad
        elif 'ac3d' in dir(acad_translator):
            acad = acad_translator.ac3d
            
        self.documents = acad.Documents
        self.doc = self.active_document_finder
        self.model = CastTo(self.doc.ModelSpace, 'IAcadModelSpace')

        Utility = self.doc.Utility

        self.GetPoint = Utility.GetPoint
        self.GetDist = Utility.GetDistance
        self.PRINC = Utility.Prompt
        self.Coordinate = acad_translator.POINT
        self.Coordinates = acad_translator.POINT_LIST

        self.LWPolyline = self.model.AddLightWeightPolyline
        self.Line = self.model.AddLine
        self.Circle = self.model.AddCircle
        self.Point = self.model.AddPoint
        self.MText = self.model.AddMText
        self.Text = self.model.AddText

        self.New_Layer = self.doc.Layers.Add
        
        pass
    
    @property
    def active_document_finder(self):
        for item in self.documents:
            if item.Active == True:
                return item
            pass
        pass

    @property
    def EntSel(self):
        try:
            ent = self.doc.Utility.GetEntity()[0]
            ent = CastTo(ent, ent.__class__.__name__)
            return ent
        except Exception as er:
            print(f'erro : {er}'.title())