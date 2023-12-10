# ECDSA implementation
from ecpy.curves import Curve, Point
from sha3 import keccak_256
import random

priv_key = 0xfd44726da764aa11502b13616e44108f6600eab7f8505e385d13ed78a24178b8

#generate the public key using that private key 
curve = Curve.get_curve('secp256k1')

# curve order for secp256k1
n = 115792089237316195423570985008687907852837564279074904382605163141518161494337 

# generator point coordinates
x = 55066263022277343669578718895168534326250603453777594175500187360389116729240 
y = 32670510020758816978083085130507043184471273380659243275938904335757337482424

# instantiate Point from generator point coordinates
G = Point(x, y, curve)

# generate public key
pub_key = priv_key * G 

# { 0x56890c969e1f91ca4eb359ee516d425058056d578755ebdd30be660d492b306d,
# 0x356527958d5d690f99102ad5ec10eabd7c938b6fa3d2ea47e9e0658ede6a19c3 }

# hash message m to produce h  

# byte string
msg = b'hola mundo' 

# hash message
h_bytes = keccak_256(msg).digest() 

# convert to int for signature proof calc
h = int.from_bytes(h_bytes, byteorder='big')

# sign m using your private key and a randomly chosen nonce k. 

# generate random k in range 1... n-1
k = random.randint(1, n-1) 
print('k  : ', k)

# calculate random point R
R = k * G

# extract x-coordinate
r = R.x

# calculate signature proof
# s = k^-1 * (h + r * priv_key) (mod n)
s = (pow(k, -1, n) * (h + r * priv_key)) % n

#verify (r, s, h, PubKey) is valid 

# calculate modular inverse of the signature proof
s1 = pow(s, -1, n)

# s1 = s^-1
#    = (k^-1 * (h + r * priv_key))^-1
#    = k * (h + r * priv_key)^-1 

# recover the point
Rp = (h * s1) * G + (r * s1) * pub_key 

# Rp = (h * s1) * G + (r * s1) * priv_key * G
#    = (h + r * priv_key) * s1 * G
#    = (h + r * priv_key) * k * (h + r * priv_key)^-1 * G
#    = k * G

# extract x-coordinate
rp = Rp.x

# verify signature validation
print('r  : ', r, '\nrp : ', rp)
assert(r == rp)

# as a function
def verify_signature(r, s, h, pub_key):
    
    '''
    Returns signature proof validity status.

            Args:
                    r (int): x-coordinate of randomly chosen point
                    s (int): signature proof
                    h (int): message hash
                    pub_key (Point): known pub key for signature

            Returns:
                    bool: whether signature is valid
    '''
    curve = Curve.get_curve('secp256k1')

    # curve order for secp256k1
    n = 115792089237316195423570985008687907852837564279074904382605163141518161494337 

    # generator point coordinates
    x = 55066263022277343669578718895168534326250603453777594175500187360389116729240 
    y = 32670510020758816978083085130507043184471273380659243275938904335757337482424
    
    Rp = pow(s, -1, n) * (Point(x, y, curve) * h + r * pub_key)
    
    return r == Rp.x 

print(verify_signature(r, s, h, pub_key))