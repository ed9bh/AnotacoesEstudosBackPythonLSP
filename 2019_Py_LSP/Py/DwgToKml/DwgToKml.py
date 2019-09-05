'''
//////////////////////////// By: Eric Drumond - 04/2017 (ed9bh)
//////////////////////////// Conversor de DWG para KML
//////////////////////////// Lisp de mesmo nome necessario para execução desda Conversão
'''
import os
import sys
# TKINTER - Modulo do Programa
from tkinter import *
# UTM - Conversor de coordenadas - WGS84
import utm
# Interpretador - KML
import pyeasykml as KML

#'''
flagDir = sys.argv[1][0:] # ***** Olhar arqumento em linha de comando *****
print(flagDir)
os.chdir(flagDir)
basefile = os.listdir(flagDir)

# os.
global fileexist
try:
    for i in basefile:
        if i == 'dwgtokml.asc':
            fileexist = True
    # print(basefile)
    # print(fileexist)
except:
    fileexist = False
    (print("Arquivo \"ESSENCIAL\" não encontrado... Programa finalizado!!!"))
    quit()

#'''

#flagDir = "C:\\Users\\Eric\\Dropbox\\Work\\Desenvolvimento\\Python\\Projetos\\DwgToKml\\"
file = open(flagDir + 'dwgtokml.asc', 'r')

root = Tk()

class Programa:
    def infFQ(self, event=NONE):
        global fusoCheck
        global quadCheck
        try:
            for i in ("c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "x"):
                if i == self.quad.get():
                    quadCheck = True
                    break
                else:
                    quadCheck = False
            for i in range(1, 60):
                if i == self.fuso.get():
                    fusoCheck = True
                    break
                else:
                    fusoCheck = False
        except:
            fusoCheck = False
            quadCheck = False
        else:
            self.butt.set("Aguardando informações!!!")
            self.execButt.unbind("<Button-1>")
            self.execButt.config(state=DISABLED)
        finally:
            if (quadCheck == True) and (fusoCheck == True):
                self.execButt.bind("<Button-1>", self.convert)
                self.execButt.config(state=NORMAL)
                self.butt.set("Converter")

    def makePline(self, lay, cor, coordlist):
        for wf in (KML.Polilinha(lay, cor, coordlist)):
            self.fileKML.writelines(wf)
        # print("Linha Criada")

    def makePonto(self, lay, x, y):
        for wf in (KML.Ponto(lay, x, y)):
            self.fileKML.writelines(wf)
        # print("Ponto Criado")

    def makeHatch(self, lay, cor, coordlist):
        for wf in (KML.Hatch(lay, cor, coordlist)):
            self.fileKML.writelines(wf)

    def convert(self, event=NONE):
        self.fusoEtry.unbind("<Key>")
        self.fusoEtry.config(state=DISABLED)
        self.quadEtry.unbind("<Key>")
        self.quadEtry.config(state=DISABLED)
        self.butt.set("Aguardando o Termino do Processo!!!")
        self.execButt.unbind("<Button-1>")
        self.execButt.config(state=DISABLED)
        # Area do processamento
        self.fileKML = open(flagDir + 'temporario.kml', 'w') #
        self.fileKML.writelines(KML.InicioKML())
        self.ent = False
        self.lay = False
        self.cor = False
        self.coords = []
        for i in file.readlines():
            self.info = i.split()
            # print(str(self.info[0]))
            if (self.info[0] == 'Linha') and (self.ent == False):
                self.ent = self.info[0]
            elif (self.info[0] == 'Ponto') and (self.ent == False):
                self.ent = self.info[0]
            elif (self.info[0] == 'Hatch') and (self.ent == False):
                self.ent = self.info[0]
            elif (self.lay == False) and (self.ent != False):
                self.lay = self.info[0]
            elif (self.cor == False) and (self.lay != False):
                self.cor = KML.corCadHex(int(self.info[0]))
                print(self.cor)
            elif len(self.info) == 2 and (self.cor != False):
                self.x = float(self.info[0])
                self.y = float(self.info[1])
                #print(utm.to_latlon(self.x, self.y, self.fuso.get(), self.quad.get()))
                self.LatLon = (utm.to_latlon(self.x, self.y, self.fuso.get(), self.quad.get()))
                self.coords.append((self.LatLon[1],self.LatLon[0]))
            elif (self.info[0] == 'Final'):
                try:
                    if self.ent == 'Linha':
                        self.makePline(self.lay, self.cor, self.coords)
                    elif self.ent == 'Ponto':
                        self.makePonto(self.lay, self.coords[0][0], self.coords[0][1])
                    elif self.ent == 'Hatch':
                        self.makeHatch(self.lay, self.cor, self.coords)
                except:
                    pass
                self.ent = False
                self.lay = False
                self.cor = False
                self.coords = []
            else:
                pass

            '''
            if self.info[0] != False:
                print(self.info, self.ent, self.lay, self.cor)
            '''
        # ---------------------
        print("Tudo bem até aqui...")
        self.fileKML.writelines(KML.FinalKML())
        try:
            file.close()
        except:
            pass
        try:
            self.fileKML.close()
        except:
            pass
        try:
            root.destroy()
        except:
            pass

    # Inicialização
    root.title("DWG to KML...")
    root.geometry("320x200+600+200")
    root.resizable(False, False)
    Label(root, text="Insira as informações abaixo para Conversão").grid(row=0, column=0, columnspan=10, padx=9, pady=9)
    Label(root, text="ATENÇÂO!!! Apenas para WGS84 e SIRGAS2000!!!").grid(row=1, column=0, columnspan=10, padx=9, pady=9)
    Label(root, text="Fuso:").grid(row=2, column=0, padx=9, pady=9)
    Label(root, text="Letra Quadrante:").grid(row=3, column=0, padx=9, pady=9)

    def __init__(self, event=NONE):
        self.fuso = IntVar() # 1 a 60
        self.quad = StringVar() # c a x
        self.butt = StringVar()
        self.fuso.set("Fuso de \"1\" a \"60\"")
        self.quad.set("Quadrante de \"C\" a \"X\"")
        self.fusoEtry = Entry(root, textvariable=self.fuso)
        self.fusoEtry.focus()
        self.fusoEtry.bind("<Key>", self.infFQ)
        self.quadEtry = Entry(root, textvariable=self.quad)
        self.quadEtry.focus()
        self.quadEtry.bind("<Key>", self.infFQ)
        self.execButt = Button(root, textvariable=self.butt, width=40, height=1)
        self.fusoEtry.grid(row=2, column=1, padx=9, pady=9)
        self.quadEtry.grid(row=3, column=1, padx=9, pady=9)
        self.execButt.grid(row=4, column=0, columnspan=20, padx=9, pady=9)
        self.butt.set("Aguardando informações!!!")
        self.execButt.unbind("<Button-1>")
        self.execButt.config(state=DISABLED)

Programa(root)
root.mainloop()


# Ganhar tempo para não conflitar com o Lisp
import time
time.sleep(3)
try:
    os.remove(flagDir + 'dwgtokml.asc')
except:
    pass
os.renames(flagDir + 'temporario.kml', flagDir + 'dwgtokml.kml')
print("Ação concluida...")