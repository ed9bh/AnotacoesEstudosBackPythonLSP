from comtypes.client import GetActiveObject, CreateObject

try:
    excel = GetActiveObject('Excel.Application')
    pass
except Exception as error:
    print(error)
    quit()

workbook = excel.WorkBooks.Add()
sheet = workbook.Sheets(1)

excel.Visible = True

sheet.Range('A1:E1').Value[:] = (1, 2, 3 , 4 , 5)

print('Done...')