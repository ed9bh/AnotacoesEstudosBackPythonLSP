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


class Wallet():
    def __init__(self, capital_disponivel, valor_titulos, valor_rend, capital_usado, geracao=0):
        self.capital_disponivel = capital_disponivel
        self.valor_titulos = valor_titulos
        self.valor_rend = valor_rend
        self.capital_usado = capital_usado
        self.geracao = geracao
        self.nota_avaliacao = 0
        self.capital_usados = 0
        self.cromossomo = []

        for i in range(len(capital_usado)):
            if random() < 0.5:
                self.cromossomo.append(1)
                pass
            else:
                self.cromossomo.append(0)
                pass
            pass
        pass

    def avaliacao(self):
        nota = 0
        capital = 0
        for i in range(len(self.cromossomo)):
            if self.cromossomo[i] == 1:
                nota += self.valor_rend[i]
                capital += self.valor_titulos[i]
                pass
            if capital > self.capital_disponivel:
                nota = 1
                pass
            pass
        self.nota_avaliacao = nota
        self.capital_usado = capital
        pass

    def crusamento(self, other):
        corte = round(random() * len(self.cromossomo))

        filho_1 = other.cromossomo[0:corte] + self.cromossomo[corte::]
        filho_2 = self.cromossomo[0:corte] + other.cromossomo[corte::]

        filhos = [
            Wallet(self.capital_disponivel, self.valor_titulos,
                   self.valor_rend, self.capital_usado, self.geracao + 1),
            Wallet(self.capital_disponivel, self.valor_titulos,
                   self.valor_rend, self.capital_usado, self.geracao + 1)
        ]

        filhos[0].cromossomo = filho_1
        filhos[1].cromossomo = filho_2

        return filhos

    def mutacao(self, taxa_mutacao):
        for i in range(len(self.cromossomo)):
            if random() < taxa_mutacao:
                if self.cromossomo[i] == 1:
                    self.cromossomo[i] == 0
                    pass
                else:
                    self.cromossomo[i] == 1
        return self
# %%
