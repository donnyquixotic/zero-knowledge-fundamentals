import time
from sympy import discrete_log

#***execution time differences using elementary operators vs. pow()***

s = time.time()
ans = 1002583 ** 939001 % 2003951
t = time.time()

print("calculating {} operation using elementary operators took {:.2f} seconds".format(ans, t - s))

s = time.time()
ans = pow(1002583,939001,2003951)
t = time.time()

print("calculating {} operation using pow() took {:.2f} seconds".format(ans, t - s))

#***solving for encrypted number***

n = 9551
g = 5
encrypted_number = 5666

# brute force solution

s = 0 

while (g ** s) % n != encrypted_number:
    s += 1

assert pow(g, s, n) == encrypted_number
print("brute force solution is {}".format(s))

# using discrete_log

n = 1000004119
g = 5
encrypted_number = 767805982

s = discrete_log(n, encrypted_number, g) # log_g(encrypted_number) (mod n)

assert pow(g, s, n) == encrypted_number
print("discrete solution is {}".format(s))

# ***zk addition***

a = 3779
b = 7727

assert(pow(g, a, n) * pow(g, b, n) % n == pow(g, a + b, n)) 

#***zk subtraction using modular inverse***

a = 22
n = 9551
assert(pow(g, a, n) * pow(g, -a, n) % n == 1)

a_inv = a ** (n - 2) % n
assert(a_inv * a % n == 1)

#***multiplication by constant***

a = 15
assert(pow(g, a, n) * pow(g, a, n) * pow(g, a, n) * pow(g, a, n) % n == pow(g, a * 4, n))

assert(pow(pow(g, a, n), 4 , n) == pow(g, a * 4, n))


#***zk solution to system of equations given g and n***

g = 57
n = 101
r_1 = 7944
r_2 = 4764

# 2x + 8y = 7944
# 5x + 3y = 9528

# 5(2x + 8y) = 5(7944)
# 2(5x + 3y) = 2(4764)

# 10x + 40y = 39720
# 10x + 6y = 9528

#(10x + 40y) - (10x + 6y) = 39720 - 9528

# 34y = 30192
# 2x = 840

y = 888
x = 420

# (g^x)^2 == g^x * g^x == pow(g, x, n) * pow(g, x, n) == pow(g, 2 * x, n) 
# pow(g, 8 * y, n), etc

assert(pow(g, 2 * x, n) * pow(g, 8 * y, n) % n  == pow(g, r_1, n)) 
assert(pow(g, 2 * x + 8 * y, n) % n == pow(g, r_1, n)) 

assert(pow(g, 5 * x, n) * pow(g, 3 * y, n) % n == pow(g, r_2, n)) 
assert(pow(g, 5 * x + 3 * y, n) % n == pow(g, r_2, n)) 

# demonstrating with more equations

r_3 = 7 * x + 11 * y # 12708
assert(pow(g, 7 * x + 11 * y, n) % n == pow(g, r_3, n)) 

r_4 = 3 * x + 37 * y  # 34116
assert(pow(g, 3 * x + 37 * y, n) % n == pow(g, r_4, n)) 

#***convert rational number to finite field element***

# 53/192 + 61/511 (mod 1033)

p = 1033 

n_1 = 53
n_2 = 61

d_1 = 192
d_2 = 511

# calculate inverse of denomitor
d_1i = pow(d_1, -1, p)
d_2i = pow(d_2, -1, p)

# confirm inverse is calculated correctly
assert(d_1 * d_1i % p == 1) 

# for each fraction, multiply the numerator by the inverse of the denominator 
f_1 = n_1 * d_1i 
f_2 = n_2 * d_2i 

print(d_1i, d_2i, f_1, f_2)

# take the sum modulo p
f_s = (f_1 + f_2) % p

# verify solution
n_s = 38795
d_s = 98112

d_si = pow(d_s, -1, p)

f_v = n_s * d_si % p

assert(f_s == f_v)

