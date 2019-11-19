def mme(MME: 0, n, P):
    try:
        return MME + (2 / (n + 1)) * (P - MME)
    except:
        return 0