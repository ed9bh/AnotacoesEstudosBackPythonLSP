
# coding: utf-8

# <img src="baskara.jpg" width=125 height=182>

import matplotlib.pyplot as plt


class baskara:
    def __init__(self, a, b, c):
        self.a = a
        self.b = b
        self.c = c
        self.lx = []
        self.ly = []
        self.delta = None
        self.x1 = None
        self.x2 = None
        pass
    
    def calc(self):
        try:
            self.delta = (self.b)**2 - (4 * self.a * self.c)
            self.x1 = ((-self.b) - (self.delta ** 1/2)) / (self.a * 2)
            self.x2 = ((-self.b) + (self.delta ** 1/2)) / (self.a * 2)
            distance = max(self.x1, self.x2) - min(self.x1, self.x2)
            factor = distance / 100
            
            count = min(self.x1, self.x2)
            self.lx.append(count)
            
            for i in range(0, int(distance / factor)):
                count += factor
                self.lx.append(count)
                pass
            
            for x in self.lx:
                formula = (self.a * (x) ** 2) + (self.b * x) + self.c
                self.ly.append(formula)
                pass
            pass
        except Exception as error:
            print(error)
            pass
        pass
    
    def graf(self):
        try:
            plt.plot(self.lx, self.ly)
            plt.show()
            pass
        except Exception as error:
            print(error)
            pass
        pass
    
    def princ(self):
        try:
            print('\nf(x) = {0:.2f}x² + {1:.2f}x + {2:.2f}'.format(self.a, self.b, self.c))
            print('\nDelta = {0:.2f}\nX1 = {1:.2f}\nX2 = {2:.2f}\n'.format(self.delta, self.x1, self.x2))
            pass
        except Exception as error:
            print(error)
            pass
        pass
    
    def report(self):
        self.princ()
        self.graf()


lst = [[-5, 3, 11], [12, -3, 4], [1, -1, 11]]


for l in lst:
    bsk = baskara(l[0], l[1], l[2])
    bsk.calc()
    bsk.report()


b1 = baskara(1, -1, 8)
b1.calc()
b1.report()
