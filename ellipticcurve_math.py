from py_ecc.bn128 import eq, G1, G2, add, neg, multiply, pairing, final_exponentiate, curve_order 

def rationalAdd(p1, p2, num, den):
    '''
    Returns the sum of two rational numbers represented as elliptic curve points.

            Parameters:
                    p1 (tuple): integers representing rational number 
                    p2 (tuple): integers representing rational number
                    num  (int): integer representing the numerator of the additive result
                    den  (int): integer representing the denominator of the additive result

            Returns:
                    verified (bool): comparison result of addition result and known result
    '''
    
    p1_c = (p1[0] * pow(p1[1], -1, curve_order)) % curve_order
    p2_c = (p2[0] * pow(p2[1], -1, curve_order)) % curve_order
    p3 = (num * pow(den, -1, curve_order)) % curve_order
    
    P3 = multiply(G1, p3)

    verified = P3 == multiply(G1, p1_c + p2_c) 

    return verified


def convertMatrix(matrix):
    '''
    Converts list of sinlge integers to array of elliptical points.

            Parameters:
                    matrix (list): single dimension array of integers 
                    n       (int): number of elements in array

            Returns:
                    matrix (list): single dimension of elliptical points
    '''

    for i in range(len(matrix)):
      matrix[i] = multiply(G1, matrix[i])
  
    return matrix


def matmul(matrix, n, s, o):
    '''
    Verifies a solution to a given square matrix.

            Parameters:
                    matrix (list): square matrix of integers 
                    n       (int): dimension of matrix
                    s      (list): proposed solution represented as list of integers
                    o      (list): matrix equation values represented as array of integers

            Returns:
                    verified (bool): comparison result of solution proof 
    '''

    matrix_rows = len(matrix)
    matrix_cols = len(matrix[0]) 
    s_rows = len(s)

    # check if matricies can be multiplied
    if matrix_cols != s_rows or matrix_rows == 0 or s_rows == 0:
        print("matricies are incompitable for multiplication")
        return

    # convert to EC points
    o = convertMatrix(o)

    # perform matrix multiplication
    result = [None] * n

    for i in range(n): # matrix rows
      for j in range(n): # solution columns
    
        product = multiply(multiply(G1,s[j]), matrix[i][j])
        result[i] = add(result[i], product)

        if (j == n-1 and (result[i][0] != o[i][0] or result[i][1] != o[i][1])):
            return False
    
    return True

def verifyBilinearPairing(a, b, c, x, alpha, beta, gamma, delta):
    A_inv = neg(multiply(G1, a))
    B = multiply(G2, b)
    C = multiply(G1, c)
    X = multiply(G1, x)

    Alpha = multiply(G1, alpha)
    Beta = multiply(G2, beta)
    Gamma = multiply(G2, gamma)
    Delta = multiply(G2, delta)

    minusAB = pairing(B, A_inv)
    alphaBeta = pairing(Beta, Alpha)
    xGamma = pairing(Gamma, X)
    cDelta = pairing(Delta, C)

    # Verified result: (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    ZERO = final_exponentiate(pairing(G2, G1) * pairing(G2, neg(G1)))

    pairingSum = final_exponentiate(minusAB * alphaBeta * xGamma * cDelta)

    return eq(pairingSum,ZERO)

# **************Example Usage***************
# p1 = (1, 2)
# p2 = (1, 2)
# num = 2
# den = 2
# print(rationalAdd(p1, p2, num, den))

# matrix = [1, 2, 3]
# print(convertMatrix(matrix))

# matrix = [[3, 4, 5], [1, 3, 9], [5, 1, 2]]
# n = 3
# s = [7, 11, 13] 
# o = [130, 157, 72]
# print(matmul(matrix, n, s, o))

# ab = alpha(beta) + x(gamma) + c(delta)
# 0 = -AB + Alpha(Beta) + X(Gamma) + C(Delta)
# (7 * 12) = (2 * 4) + (3 * 6) + (2 * 29)  
# print(verifyBilinealPairing(7, 12, 2, 3, 2, 4, 6, 29)) 
