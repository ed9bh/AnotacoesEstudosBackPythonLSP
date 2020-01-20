# %%

class Rectangle():
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.stats
        pass

    @property
    def stats(self):
        self.area = self.height * self.width
        self.length = (self.height * 2) + (self.width * 2)
        return self.area, self.length
        pass
    pass

class Square(Rectangle):
    def __init__(self, height):
        super().__init__(height, height)

# %%
a = Rectangle(width=10, height=12)
a.stats
# %%
b = Square(height=20)
b.stats
# %%
