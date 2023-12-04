import numpy as np
import random

def verifyConstraint(A, B, C, w):
  return (np.multiply(A.dot(w), B.dot(w)) == C.dot(w))

x = random.randint(1,1000)
y = random.randint(1,1000)

o  = 5 * x**3 - 4 * y**2 * x**2 + 13 * x * y**2 + x**2 - 10*y
v1 = x**2
v2 = y**2
v3 = 5 * x * v1
v4 =-4 * v2 * v1

w = [1, o, x, y, v1, v2, v3, v4]

A = np.array([	[0,  0,  1,  0,  0,  0,  0,  0],
		[0,  0,  0,  1,  0,  0,  0,  0],
	      	[0,  0,  5,  0,  0,  0,  0,  0],
		[0,  0,  0,  0,  0, -4,  0,  0],
		[0,  0, 13,  0,  0,  0,  0,  0]	])

B = np.array([	[0,  0,  1,  0,  0,  0,  0,  0],
		[0,  0,  0,  1,  0,  0,  0,  0],
		[0,  0,  0,  0,  1,  0,  0,  0],
		[0,  0,  0,  0,  1,  0,  0,  0],
		[0,  0,  0,  0,  0,  1,  0,  0]	])

C = np.array([	[0,  0,  0,  0,  1,  0,  0,  0],
		[0,  0,  0,  0,  0,  1,  0,  0],
		[0,  0,  0,  0,  0,  0,  1,  0],
		[0,  0,  0,  0,  0,  0,  0,  1],
		[0,  1,  0, 10, -1,  0, -1, -1]	])

print(verifyConstraint(A,B,C,w))

# Compute and verify R1CS for the following:
# fn main(x: field, y: field) -> field {
#   return 5*x**3 - 4*y**2*x**2 + 13*x*y**2 + x**2 - 10*y
# }

# v1 = x^2                                =    x * x
# v2 = y^2                                =    y * y
# v3 = 5x(v1)                             =   5x * v1
# v4 = -4v2(v1)                           = -4v2 * v1
# out + 10y - v1 - v3 - v4 = 13x(v2)      =  13x * v2

# out = 5x*v1 - 4y^2*v1 + 13xy^2 + v1 - 10y
# out = 5x*v1 - 4v2*v1  + 13xv2  + v1 - 10y
# out = v3    - 4v2*v1  + 13xv2   + v1 - 10y
# out = v3    + v4      + 13xv2   + v1 - 10y
# out - v3 - v4 - v1 + 10y = 13x(v2)

# W = [1, o, x, y, v1, v2, v3, v4]

# LHS
# 1  o  x  y v1 v2 v3 v4
# 0  0  1  0  0  0  0  0
# 0  0  0  1  0  0  0  0
# 0  0  5  0  0  0  0  0
# 0  0  0  0  0 -4  0  0
# 0  0 13  0  0  0  0  0

# RHS
# 1  o  x  y v1 v2 v3 v4
# 0  0  1  0  0  0  0  0
# 0  0  0  1  0  0  0  0
# 0  0  0  0  1  0  0  0
# 0  0  0  0  1  0  0  0
# 0  0  0  0  0  1  0  0

# O
# 1  o  x  y v1 v2 v3 v4
# 0  0  0  0  1  0  0  0
# 0  0  0  0  0  1  0  0
# 0  0  0  0  0  0  1  0  
# 0  0  0  0  0  0  0  1  
# 0  1  0 10 -1  0 -1 -1
