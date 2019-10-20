# %%
from os import chdir
from random import random, randint, randrange
from matplotlib import pyplot as plt
import pandas as pd

# %%


class Titulo():
    def __init__(self, Nome, Rend_Mes, Preco, VPA, Prazo):
        self.Nome = Nome
        self.Rend_Mes = Rend_Mes
        self.Preco = Preco
        self.VPA = VPA
        self.P_VPA = self.Preco / self.VPA
        self.Prazo = Prazo
        pass

# %%


class Individuo():
    def __init__(self, nome, preco, limite_investimento, P_VPA, Rend, Prazo, geracao=0):
        self.preco = preco
        self.limite_investimento = limite_investimento
        self.P_VPA = P_VPA
        self.Rend = Rend
        self.Prazo = Prazo
        self.geracao = geracao
        self.nota_avaliacao = 0
        self.limite_usado = limite_investimento - preco
        self.cromossomo = []

        # 1
        if P_VPA < 1.1:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 2
        if P_VPA < 1.5:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 3
        if P_VPA < 1.0:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 4
        if (self.Rend / self.preco) > 0.005:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 5
        if (self.Rend / self.preco) > 0.0075:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 6
        if (self.Rend / self.preco) > 0.01:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 7
        if (self.Rend / self.preco) > 0.0125:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 8
        if (self.Rend / self.preco) > 0.015:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 9
        if (self.Rend / self.preco) > 0.015:
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 10
        if self.preco < (limite_investimento / 5):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 11
        if self.preco < (limite_investimento / 4):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 12
        if self.preco < (limite_investimento / 3):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 13
        if self.preco < (limite_investimento / 2):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 14
        if self.preco < (limite_investimento / 1.75):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 15
        if self.preco < (limite_investimento / 1.5):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 16
        if self.preco < (limite_investimento / 1.25):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 17
        if self.preco < (limite_investimento / 1.125):
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        # 18
        if self.Prazo == 'Indeterminado':
            self.cromossomo.append(1)
            pass
        else:
            self.cromossomo.append(0)
            pass

        if preco >= limite_investimento:
            self.cromossomo = [0 for _ in range(18)]
            pass

        for gen in self.cromossomo:
            self.nota_avaliacao += gen
            pass

# %%
