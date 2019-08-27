from numpy import degrees, arccos, arcsin, trunc, pi

class TroncoDePiramide:
    def __init__(self, Area01=float, Elev01=float, Area02=float, Elev02=float):
        self.Area01 = Area01
        self.Area02 = Area02
        self.Elev01 = Elev01
        self.Elev02 = Elev02
        self.value = self.Calc()
        pass
    
    def Calc(self):
        h = abs(self.Elev01 - self.Elev02)
        s = (self.Area01 + self.Area02 + (max(self.Area01, self.Area02) * min(self.Area01, self.Area02))**(1/2))
        tp = h * s
        return tp
    
    pass

# tp = TroncoDePiramide(Area01=248, Elev01=27, Area02=947, Elev02=1200)
# print(tp.value)
