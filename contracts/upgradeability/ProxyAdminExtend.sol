// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.20;
 
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
 
/**
* @dev ProxyAdminExtend is a contract inherited from ProxyAdmin,
 * which has no other implementation .
*/
contract ProxyAdminExtend is ProxyAdmin {
        constructor(address initialOwner) ProxyAdmin(initialOwner){
    }
}