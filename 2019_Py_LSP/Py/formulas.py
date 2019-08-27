# %%
try:
    %matplotlib inline
    pass
except Exception as error:
    print(error)
    pass

from matplotlib import pyplot as plt
from numpy import degrees, radians, sign, arccos, arcsin, pi, e, real, array, tan
from math import floor, trunc, log, log10, erf
from functools import reduce
import pandas as pd
# %%
# Tronco de Piramide


class TroncoPiramide:
    def __init__(self, Area01, Elev01, Area02, Elev02):
        self.Area01 = Area01
        self.Area02 = Area02
        self.Elev01 = Elev01
        self.Elev02 = Elev02
        self.Resultado = None

        self.calc()

    def calc(self):
        h = abs(self.Elev01 - self.Elev02)
        s = (self.Area01 + self.Area02 + (max(self.Area01, self.Area02)
                                          * min(self.Area01, self.Area02)) ** (1 / 2))
        self.Resultado = h * s
        return self.Resultado

    def __add__(self, other):
        return self.Resultado + other.Resultado

    def __sub__(self, other):
        return self.Resultado - other.Resultado

# %%
# Angulo Central


class AC:
    def __init__(self, Point1=[], Point2=[], Point3=[]):
        self.Point1, self.Point2, self.Point3 = Point1, Point2, Point3
        self.Facos = None
        self.Fasin = None
        self.ANGLE = None

        self.calc()
        print(str(self))

    def calc(self):
        A = (((self.Point1[0] - self.Point3[0])**2) +
             ((self.Point1[1] - self.Point3[1])**2)) ** (1/2)
        B = (((self.Point2[0] - self.Point3[0])**2) +
             ((self.Point2[1] - self.Point3[1])**2)) ** (1/2)
        C = (((self.Point1[0] - self.Point2[0])**2) +
             ((self.Point1[1] - self.Point2[1])**2)) ** (1/2)

        Form1 = (A)**2 - (B)**2 - (C)**2
        Form2 = (B * C) * 2
        Form3 = Form1 / Form2

        self.Facos = arccos(Form3)
        self.Fasin = arcsin(Form3)

        ANG = trunc(degrees(self.Facos))
        ANG = '{:0003.0f}°'.format(ANG)

        MIN = int(
            ((int((degrees(self.Facos) - int(degrees(self.Facos))) * 100)) / 100) * 60)
        MIN = '{:02d}\''.format(MIN)

        SEC = (degrees(self.Facos * 100) - int(degrees(self.Facos * 100))) * 60
        SEC = '{:002.2f}"'.format(SEC)

        self.ANGLE = ANG + MIN + SEC

        self.Facos = degrees(self.Facos)
        self.Fasin = degrees(self.Fasin)

        return self.Facos, self.Fasin

    def __str__(self):
        return 'AC : {}'.format(self.ANGLE) + '\nAC // ACOS : {0:0.6f}\nAC // ASIN : {1:0.6f}'.format(self.Facos, self.Fasin)
# %%


def fibo(n):
    a, b = 0, 1
    while b < n:
        print(b)
        a, b = b, a+b
        pass
    pass
# %%
# Largura de Pista Mineração


class LPistaMineracao:
    def __init__(self, NumeroDeVias, LarguraVeiculo):
        self.NumeroDeVias = NumeroDeVias
        self.LarguraVeiculo = LarguraVeiculo
        self.Largura = None

        self.calc()
        print('Largura de Pista (NR-22) : {:00.02f}m'.format(self.Largura))
        pass

    def calc(self):
        self.Largura = ((1.5 * self.NumeroDeVias) + 0.5) * self.LarguraVeiculo
        return self.Largura

    def __add__(self, other):
        return self.Largura + other.Largura

    def __sub__(self, other):
        return self.Largura - other.Largura

# %%
# Tabelas DNIT
VelocidadesDiretrizes = pd.DataFrame(
    data=[
        [100, 100, 80, 60],
        [80, 80, 60, 40],
        [60, 60, 40, 30]
    ],
    index=['Planas', 'Onduladas', 'Montanhosas'],
    columns=['Classe Especial', 'Classe I', 'Classe II', 'Classe III']
)
# VelocidadesDiretrizes
# VelocidadesDiretrizes['Classe II']['Planas']

RaioMinCurvHoriz = pd.DataFrame(
    data=[
        [430, 340, 200, 110],
        [280, 200, 110, 50],
        [160, 100, 30, 30]
    ],
    index=['Planas', 'Onduladas', 'Montanhosas'],
    columns=['Classe Especial', 'Classe I', 'Classe II', 'Classe III']
)

DeclividadesLongitudinais = pd.DataFrame(
    data=[
        [0.03, 0.03, 0.03, 0.04],
        [0.04, 0.04, 0.04, 0.05],
        [0.05, 0.05, 0.06, 0.07]
    ],
    index=['Planas', 'Onduladas', 'Montanhosas'],
    columns=['Classe Especial', 'Classe I', 'Classe II', 'Classe III']
)

# %%
for report in (DeclividadesLongitudinais, VelocidadesDiretrizes, RaioMinCurvHoriz):
    report.plot()

# %%

fig, axs = plt.subplots(1, 3, figsize=(5, 5))

try:
    axs[0].plot(DeclividadesLongitudinais)
    axs[1].hist(VelocidadesDiretrizes['Montanhosas':])
    axs[2].plot(RaioMinCurvHoriz)
except Exception as error:
    print(error)
    pass

# %%
