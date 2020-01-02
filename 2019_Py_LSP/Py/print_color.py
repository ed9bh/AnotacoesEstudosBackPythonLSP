# %%
from os import system

# %%
system('color')


class cor:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
# ---
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    UNDERLINE = '\033[4m'
    pass

# %%
print(
    f'{cor.HEADER}Teste de cores...{cor.END}\n'
    f'{cor.RED}Red..\n'
    f'{cor.BLUE}Blue..\n'
    f'{cor.GREEN}Green..\n'
    )

# %%%
print(f'{cor.BOLD} *** Tabela de Estilos *** {cor.END}')
for c in range(108):
    print(f'\033[{c:0.0f}m{c:03}...\033[0m\t', end='')