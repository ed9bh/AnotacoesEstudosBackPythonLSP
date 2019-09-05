import openpyxl
import random

print(openpyxl.__version__)



wb = openpyxl.Workbook()
sheet = wb.create_sheet('MyTeste')

for i in range(1, 11):
    sheet['A' + str(i)].value = random.randint(1, 9999)

wb.save('Teste.xlsx')