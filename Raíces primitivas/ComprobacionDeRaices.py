def phi(n):
    resultado = n
    i = 2
    while i * i <= n:
        if n % i == 0:
            while n % i == 0:
                n //= i
            resultado -= resultado // i
        i += 1
    if n > 1: 
        resultado -= resultado // n
    return resultado

def factores_primos(n):
    factores = []
    i = 2
    while i * i <= n:
        if n % i == 0:
            factores.append(i)
            while n % i == 0:
                n //= i
        i += 1
    if n > 1:
        factores.append(n)
    return factores

def es_raiz_primitiva(g, p):
    if g <= 1 or g >= p:
        return False

    phi_p = p - 1
    factores = factores_primos(phi_p)

    for q in factores:
        if pow(g, phi_p // q, p) == 1:
            return False

    return True

def raices_primitivas(p):
    primitivas = []
    for g in range(2, p):
        if es_raiz_primitiva(g, p):
            primitivas.append(g)
    return primitivas

if __name__ == "__main__":
    p = 32749
    pLista = raices_primitivas(p)
    nums = list(map(int, input().split()))
    if(pLista == nums):
        print("Son iguales")
    else:
        print("Son diferentes")
        #print(pLista)
        #print(nums)