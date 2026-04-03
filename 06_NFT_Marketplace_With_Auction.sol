// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplaceWithAuction {
    enum ListingType { FIXED_PRICE, AUCTION }
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        uint256 minBid;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        ListingType listingType;
        bool active;
    }

    uint256 public listingCount;
    mapping(uint256 => Listing) public listings;
    uint256 public platformFee = 250;

    event Listed(uint256 id, address seller, address nft, uint256 tokenId, uint256 price, ListingType typ);
    event Sold(uint256 id, address buyer, uint256 price);
    event Bid(uint256 id, address bidder, uint256 amount);

    function listNFT(address nft, uint256 tokenId, uint256 price, ListingType typ) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        listingCount++;
        listings[listingCount] = Listing(msg.sender, nft, tokenId, price, 0, 0, address(0), 0, typ, true);
        emit Listed(listingCount, msg.sender, nft, tokenId, price, typ);
    }

    function buy(uint256 listingId) external payable {
        Listing storage l = listings[listingId];
        require(l.active && l.listingType == ListingType.FIXED_PRICE && msg.value == l.price);
        l.active = false;
        IERC721(l.nftContract).transferFrom(address(this), msg.sender, l.tokenId);
        emit Sold(listingId, msg.sender, msg.value);
    }

    function bid(uint256 listingId) external payable {
        Listing storage l = listings[listingId];
        require(l.active && l.listingType == ListingType.AUCTION && msg.value > l.highestBid);
        l.highestBid = msg.value;
        l.highestBidder = msg.sender;
        emit Bid(listingId, msg.sender, msg.value);
    }
}
