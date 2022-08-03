//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

// import ERC1155 token contract from openzippelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";

// import  Ownable.sol for using onlyOwner modifier in our func
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract NFTContract is ERC1155, Ownable {
    uint256 public constant ARTWORK = 0; // nft name artwork and id 0
    uint256 public constant PHOTO = 1; // nft name PHOTO and id 1

    // ERC1155 takes a URI ( address where our metadata of NFT is hosted)
    // "https://lxv0tzuupmtf.usemoralis.com" (base uri)  this is waht we get after hosting metadata at moralis
    constructor() ERC1155("https://lxv0tzuupmtf.usemoralis.com/{id}.json") {
        // uinsg the _mint function whose attributes are , account , id, amount(no of ) ,""(internal realted to func)
        _mint(msg.sender, ARTWORK, 1, "");
        _mint(msg.sender, PHOTO, 2, "");
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        _mint(account, id, amount, "");
    }

    //Function to burn "your" token
    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        require(msg.sender == account);
        _burn(account, id, amount);
    }
}
