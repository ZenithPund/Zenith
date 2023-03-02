//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZenithPunks is  Ownable, ERC721Enumerable {

    uint256 public mintPrice;
    uint256 public myTotalSupply;
    uint256 public maxSupply;

    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    mapping(address => uint256) public walletMints;

    constructor() payable ERC721('ZenithPunks', 'PUNK')
    {
        mintPrice = 100 ether;
        myTotalSupply = 30;
        maxSupply = 2500;
    }

    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner {
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        baseTokenUri = baseTokenUri_;
    }

    function tokenURI (uint256 tokenId_) public view override returns (string memory){
        require(_exists(tokenId_), 'Token does not exist');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId_), ".json"));
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}('');
        require(success);
    }

    function mint(uint256 quantity_) public payable{
        require(isPublicMintEnabled, 'Minting not enabled');
        require(msg.value == quantity_ * mintPrice, 'Wrong mint value');
        require(myTotalSupply + quantity_ <= maxSupply, 'Sold out');
    
        for (uint256 i = 0; i < quantity_; i++) {
            uint256 newTokenId = myTotalSupply + 1;
            myTotalSupply++;
            
            _safeMint(msg.sender, newTokenId);
        }
        walletMints[msg.sender] += quantity_;
    }

    // Reserved for giveaways
    function reserveGiveaway(uint256 amount) public onlyOwner {
        uint currentSupply = totalSupply();
        require(isPublicMintEnabled == false, "Sale has already started");
        uint256 index;
        for (index = 1; index <= amount; index++) {
            _safeMint(owner(), currentSupply + index);
        }
    }

   
}
