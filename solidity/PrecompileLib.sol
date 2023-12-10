// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/*
methods applying precompiles for addition, scalar multiplication, 
and bilineal pairing verification on elliptic curve bn128, 
and big int modular exponentiation.
 */

library math {

    struct G1Point {
	    uint256 x;
	    uint256 y;
    }

    struct G2Point {
        uint256[2] x;
        uint256[2] y;
    }

    /*
    * @return result the sum of two points of G1 input as coordinates
    */
    function add(
        uint256 x1,
        uint256 y1,
        uint256 x2,
        uint256 y2
        ) public view returns (G1Point memory result){

        (bool addOk, bytes memory addResult ) = address(6).staticcall(abi.encode(x1,y1,x2,y2));
        require(addOk, "add failed");
        (result.x, result.y) = abi.decode(addResult, (uint256, uint256));
    }

    /*
    * @return r the sum of two points of G1
    */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    /*
    * @return result scalar product of G1 input ax x,y
    */
    function mul(
        uint256 scalar,
        uint256 x1,
        uint256 y1
        ) public view returns (G1Point memory result){

        (bool mulOk, bytes memory mulResult ) = address(7).staticcall(abi.encode(x1,y1,scalar));
        require(mulOk, "scalar multiplication failed");
        (result.x, result.y) = abi.decode(mulResult, (uint256, uint256));
    }

    /*
    * @return r the product of a point on G1 and a scalar, i.e.
    *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
    *         points p.
    */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
        success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
        // Use "invalid" to make gas estimation work
        switch success case 0 { invalid() }
        }
        require(success, "pairing-mul-failed");
    }

    /*
    * @return The negation of p, i.e. p.plus(p.negate()) should be zero.
    */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        uint256 PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        // The prime q in the base field F_q for G1
        if (p.x == 0 && p.y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.x, PRIME_Q - (p.y % PRIME_Q));
        }
    }

    /*
    * @return result of the modular exponentiation of a number
    */
    function modExp(uint256 base, uint256 e, uint256 m) public returns (uint256 result) {
        assembly {
            // Free memory pointer
            let pointer := mload(0x40)

            // Define length of base, exponent and modulus. 0x20 == 32 bytes
            mstore(pointer, 0x20)
            mstore(add(pointer, 0x20), 0x20)
            mstore(add(pointer, 0x40), 0x20)

            // Define variables base, exponent and modulus
            mstore(add(pointer, 0x60), base)
            mstore(add(pointer, 0x80), e)
            mstore(add(pointer, 0xa0), m)

            // Store the result
            let value := mload(0xc0)

            // Call the precompiled contract 0x05 = bigModExp
            if iszero(call(not(0), 0x05, 0, pointer, 0xc0, value, 0x20)) {
                revert(0, 0)
            }

            result := mload(value)
        }
    }

    /*
    * @return success, whether bilineal pairing elements sum to zero
    */
    function verifyPairingArray(uint256[24] memory input) public view returns (bool success) {
        uint256 inputSize = 24;
        uint256[1] memory out;

        assembly {
            success := staticcall(gas(), 8, input, mul(inputSize, 0x20), out, 0x20)
        }
        
        require(success, "Wrong pairing");

        return out[0] != 0;
    }

    /*
    * @return success, whether bilineal pairing elements sum to zero for input passed as encoded data
    */
    function verifyPairingBytes(bytes calldata input) public view returns (bool) {
       // optional, the precompile checks this too and reverts (with no error) if false, this helps narrow down possible errors
       if (input.length % 192 != 0) revert("Points must be a multiple of 6");
       (bool success, bytes memory data) = address(0x08).staticcall(input);
       if (success) return abi.decode(data, (bool));
       revert("Wrong pairing");
    }
}
