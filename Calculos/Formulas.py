# %%
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
        self.Resultado = (h / 3) * s
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


def ProdutoEscalar(Ponto_A1=[], Ponto_A2=[], Ponto_B1=[], Ponto_B2=[]):
    X_1 = Ponto_A2[0] - Ponto_A1[0]
    X_2 = Ponto_B2[0] - Ponto_B1[0]
    Y_1 = Ponto_A2[1] - Ponto_A1[1]
    Y_2 = Ponto_B2[1] - Ponto_B1[1]

    resultado = ((X_1 * X_2) + (Y_1 * Y_2))
    
    print(resultado)

    return  resultado != 0.0
