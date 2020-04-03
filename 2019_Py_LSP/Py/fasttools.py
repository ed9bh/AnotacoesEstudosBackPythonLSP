#%%
class Counter():

    n = 0

    @property
    def i(self)->int:
        self.n += 1
        return self.n

    @property
    def d(self)->int:
        self.n -= 1
        return self.n

    pass
#%%
class Color():
    try:
        system('color')
    except:
        from os import system
        system('color')
        pass

    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    pass