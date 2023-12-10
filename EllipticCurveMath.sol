// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { math } from "./PrecompileLib.sol";

contract EllipticCurveMath {

    /*
    * @return verified solution for sum rational numbers expressed as EC points
    */
    function rationalAdd(
        math.G1Point calldata A, 
        math.G1Point calldata B, 
        uint256 num, 
        uint256 den 
        ) public returns (bool verified) {

        uint256 curve_order = 21888242871839275222246405745257275088548364400416034343698204186575808495617; 
        uint256 inv = curve_order - 2; 

        math.G1Point memory G1 = math.G1Point(1,2);
        
        uint256 Ay_inv = math.modExp(A.y, inv, curve_order);
        uint256 By_inv = math.modExp(B.y, inv, curve_order);
        uint256 den_inv = math.modExp(den, inv, curve_order);

        uint256 a = mulmod(A.x, Ay_inv, curve_order);   
        uint256 b = mulmod(B.x, By_inv, curve_order);   
        uint256 r = mulmod(num, den_inv, curve_order); 

        math.G1Point memory P = math.mul(a + b, G1.x, G1.y);
        math.G1Point memory R = math.mul(r, G1.x, G1.y);

        return (R.x == P.x && R.y == P.y);
    }

    /*
    * @return verified solution using matrices
    */
    function matmul(
            uint256[][] calldata matrix, 
            uint256 n, 
            math.G1Point[] calldata s, 
            uint256[] calldata o 
            ) public view returns ( bool verified ) {

        require(matrix[0].length == s.length, "matricies have incompatible dimensions for multiplication");
        require(matrix.length != 0 && o.length != 0 && s.length != 0, "matricies cannot be empty");

        math.G1Point[] memory oResult = new math.G1Point[](n); 
        math.G1Point[] memory matmulResult = new math.G1Point[](n);
        math.G1Point memory product;

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

    struct VerifyingKey {
        math.G1Point alpha;
        math.G2Point beta;
        math.G2Point gamma;
        math.G2Point delta;
    }

    /*
    * @return set EC points used for bilineal pairing verificaion
    */
    function verifyingKey() internal pure returns ( VerifyingKey memory vk){
        // G1, 5
        vk.alpha = math.G1Point(10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932);
        // G2, 6
        vk.beta = math.G2Point([10191129150170504690859455063377241352678147020731325090942140630855943625622, 12345624066896925082600651626583520268054356403303305150512393106955803260718], [16727484375212017249697795760885267597317766655549468217180521378213906474374, 13790151551682513054696583104432356791070435696840691503641536676885931241944]);
        // G2, 4
        vk.gamma = math.G2Point([18936818173480011669507163011118288089468827259971823710084038754632518263340, 18556147586753789634670778212244811446448229326945855846642767021074501673839], [18825831177813899069786213865729385895767511805925522466244528695074736584695, 13775476761357503446238925910346030822904460488609979964814810757616608848118]);
        // G2, 2
        vk.delta = math.G2Point([18029695676650738226693292988307914797657423701064905010927197838374790804409, 14583779054894525174450323658765874724019480979794335525732096752006891875705], [2140229616977736810657479771656733941598412651537078903776637920509952744750, 11474861747383700316476719153975578001603231366361248090558603872215261634898]);
    }

    /*
    * @return verified sum of bilinear pairings
    */

    function verifyPairing(
        math.G1Point calldata A, 
        math.G2Point calldata B, 
        math.G1Point calldata C, 
        uint256[3] memory x
    ) public view returns ( bool verified ){
        VerifyingKey memory vk = verifyingKey();
        math.G1Point memory A_inv = math.negate(A);
        math.G1Point memory G1 = math.G1Point(1,2);
        math.G1Point memory X = math.G1Point(0, 0);

        for (uint256 i = 0; i < x.length; i++) {
            X = math.plus(X, math.scalar_mul(G1, x[i]));
        }

        uint256[24] memory points = [
            A_inv.x,
            A_inv.y,
            B.x[1],
            B.x[0],
            B.y[1],
            B.y[0],
            vk.alpha.x,
            vk.alpha.y,
            vk.beta.x[1],
            vk.beta.x[0],
            vk.beta.y[1],
            vk.beta.y[0],
            X.x,
            X.y, 
            vk.gamma.x[1],
            vk.gamma.x[0],
            vk.gamma.y[1],
            vk.gamma.y[0],
            C.x,
            C.y,
            vk.delta.x[1],
            vk.delta.x[0],
            vk.delta.y[1],
            vk.delta.y[0] 
        ];

        return math.verifyPairingArray(points);
    }
}

/***Example Values that pass bilinear pairing verification***/
// A * B = alpha * beta + X * gamma + C * delta
// G1, 33
// A = [12643418736033227053786352010911706350519409749146221098915102879679320422546, 20244910942408978007550006931066140611657597349862739175933913066040413145521]
// G2, 2
// B= [[18029695676650738226693292988307914797657423701064905010927197838374790804409, 14583779054894525174450323658765874724019480979794335525732096752006891875705], [2140229616977736810657479771656733941598412651537078903776637920509952744750, 11474861747383700316476719153975578001603231366361248090558603872215261634898]];
// G1, 6
// C = [4503322228978077916651710446042370109107355802721800704639343137502100212473, 6132642251294427119375180147349983541569387941788025780665104001559216576968]
// X = G1, 6
// x = [1,2,3] 

