// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

library math {

    struct ECPoint {
	    uint256 x;
	    uint256 y;
    }

    function add(
        uint256 x1,
        uint256 y1,
        uint256 x2,
        uint256 y2
        ) public view returns (ECPoint memory result){

        (bool addOk, bytes memory addResult ) = address(6).staticcall(abi.encode(x1,y1,x2,y2));
        require(addOk, "add failed");
        (result.x, result.y) = abi.decode(addResult, (uint256, uint256));
    }

    function mul(
        uint256 scalar,
        uint256 x1,
        uint256 y1
        ) public view returns (ECPoint memory result){

        (bool mulOk, bytes memory mulResult ) = address(7).staticcall(abi.encode(x1,y1,scalar));
        require(mulOk, "scalar multiplication failed");
        (result.x, result.y) = abi.decode(mulResult, (uint256, uint256));
    }

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
}

contract EllipticCurveMath {

    function rationalAdd(
        math.ECPoint calldata A, 
        math.ECPoint calldata B, 
        uint256 num, 
        uint256 den 
        ) public returns (bool verified) {

        uint256 curve_order = 21888242871839275222246405745257275088548364400416034343698204186575808495617; 
        uint256 inv = curve_order - 2; 

        math.ECPoint memory G1;
        G1.x = 1;
        G1.y = 2;
        
        uint256 Ay_inv = math.modExp(A.y, inv, curve_order);
        uint256 By_inv = math.modExp(B.y, inv, curve_order);
        uint256 den_inv = math.modExp(den, inv, curve_order);

        uint256 a =  mulmod(A.x, Ay_inv, curve_order);   
        uint256 b = mulmod(B.x, By_inv, curve_order);   
        uint256 r = mulmod(num, den_inv, curve_order); 

        math.ECPoint memory P = math.mul(a + b, G1.x, G1.y);
        math.ECPoint memory R = math.mul(r, G1.x, G1.y);

        return (R.x == P.x && R.y == P.y);
    }


    function matmul(
            uint256[][] calldata matrix, 
            uint256 n, 
            math.ECPoint[] calldata s, 
            uint256[] calldata o 
            ) public view returns ( bool verified ) {

        require(matrix[0].length == s.length, "matricies have incompatible dimensions for multiplication");
        require(matrix.length != 0 && o.length != 0 && s.length != 0, "matricies cannot be empty");

        math.ECPoint[] memory oResult = new math.ECPoint[](n); 
        math.ECPoint[] memory matmulResult = new math.ECPoint[](n);
        math.ECPoint memory product;

        // convert values to EC point matrix
        for (uint i = 0; i < n; i++){
            oResult[i] = math.mul(o[i], 1, 2);
        }

        // perform matrix multiplication and verify points
        for (uint i = 0; i < n; i++){
            for (uint j = 0; j < n; j++){  
                
                product = math.mul(matrix[i][j], s[j].x, s[j].y);
                matmulResult[i] = math.add(matmulResult[i].x, matmulResult[i].y, product.x, product.y);

                if (j == n-1 && (matmulResult[i].x != oResult[i].x || matmulResult[i].y != oResult[i].y)){
                    return false;
                }
            }
        }

        return true;
    }

}