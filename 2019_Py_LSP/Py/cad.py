from comtypes.client import GetActiveObject

try:
	acad = GetActiveObject('AutoCAD.Application.23')
	doc = acad.ActiveDocument
	model = doc.ModelSpace
	doc.Utility.Prompt('\nCarregado com sucesso...\n')
	pass
except Exception as error:
	print(error)
	pass

EntitySelected = doc.Utility.GetEntity('\nSelecione uma linha : \n')

COR = EntitySelected[0].color
SP = EntitySelected[0].StartPoint
EP = EntitySelected[0].EndPoint
DLT = EntitySelected[0].Delta
LYR = EntitySelected[0].Layer

msg = '\nLinha com coordenada inicial em {0}, coordenada final em {1}, delta de {2}, na cor {3} e layer {4}\n'.format(SP, EP, DLT, COR, LYR)

print(msg)
doc.Utility.Prompt(msg)

