//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "IERC20.sol";
import "Ownable.sol";
import "IERC165.sol";

contract redeem is Ownable{
    address[] accounts;
    uint256 blocks;
    uint256 initialBlock;
    uint256 blocksPerWeek;
    uint256 amountPerWeek;
    mapping (address=>uint256) claimed;
    uint256 maxClaimable;
    IERC20 token;

    constructor (address [] memory _accounts, uint256 _blocksPerWeek,address _token){
        accounts=_accounts;

        initialBlock=block.number;
        maxClaimable=1000000000000000000000000;
        amountPerWeek=250000000000000000000000;
        token=IERC20(_token);
        blocksPerWeek=_blocksPerWeek;
    }

    function claim() public{
        //50400 blocks per week
        uint256 toClaim=getToClaim();
        require(toClaim>0,"Nothing to Claim");
        token.transfer(msg.sender,toClaim);
        claimed[msg.sender]=claimed[msg.sender]+toClaim;
    }

    function getToClaim() public view returns(uint256){
        uint256 toClaim=0;
        for(uint256 i=0;i<accounts.length;i++){
            if(msg.sender==accounts[i]){
                toClaim=amountPerWeek+(block.number-initialBlock)/blocksPerWeek*amountPerWeek;
                if(toClaim>maxClaimable)
                    toClaim=maxClaimable;
                toClaim=toClaim-claimed[msg.sender];
            }
        }
        return toClaim;
    }

    function addAccount(address account) public onlyOwner{
        accounts.push(account);
    }
}