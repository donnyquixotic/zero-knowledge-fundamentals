from py_ecc.bn128 import eq, G1, G2, G12, add, neg, multiply, pairing, final_exponentiate, curve_order 

# AB = alpha(beta) + X(gamma) + C(delta)

A = neg(multiply(G1,12))
B = multiply(G2, 5)
C = multiply(G1, 3)
X = multiply(G1, 6)

alpha = multiply(G1, 5)
beta  = multiply(G2, 6)
gamma = multiply(G2, 4)
delta = multiply(G2, 2)

AB        = pairing(B, A)
Cdelta    = pairing(delta, C)
Xgamma    = pairing(gamma, X)
alphaBeta = pairing(beta, alpha)

result = final_exponentiate(AB * Cdelta * Xgamma * alphaBeta)

print(result)