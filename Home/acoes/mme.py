def mme(MMA: 0, n, P):
    try:
        return MMA + (2 / (n + 1)) * (P - MMA)
    except:
        return 0
