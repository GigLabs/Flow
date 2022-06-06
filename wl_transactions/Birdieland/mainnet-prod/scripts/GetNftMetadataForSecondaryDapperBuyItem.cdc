
// Get metadata for a single NFT in a owner's collection
// needed to display the NFT in dapper wallet
// during the secondary purchase of an NFT
import Birdieland_NFT from 0x59e3d094592231a7
import NFTStorefront from 0x4eb8a10cb9f87357

pub struct PurchaseData {
    pub let id: UInt64
    pub let name: String?
    pub let amount: UFix64
    pub let description: String?
    pub let imageURL: String?

    init(id: UInt64, name: String?, amount: UFix64, description: String?, imageURL: String?) {
        self.id = id
        self.name = name
        self.amount = amount
        self.description = description
        self.imageURL = imageURL
    }
}

pub fun main(listingResourceID: UInt64, storefrontAddress: Address, expectedPrice: UFix64): PurchaseData {
    let acct = getAccount(storefrontAddress)

    // Get the storefront reference from the seller
    let storefront = acct.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
            NFTStorefront.StorefrontPublicPath
        )!
        .borrow()
        ?? panic("Could not borrow Storefront from provided address")

    // Get the listing by ID from the storefront
    let listing = storefront.borrowListing(listingResourceID: listingResourceID)
        ?? panic("No item with that ID")
    let listingDetails = listing.getDetails()

    // Get the NFT and use it to fetch set metadata
    let collectionRef = acct.getCapability(Birdieland_NFT.CollectionPublicPath)
        .borrow<&{Birdieland_NFT.Birdieland_NFTCollectionPublic}>()
        ?? panic("Could not borrow collection from address")
    let nft = collectionRef.borrowBirdieland_NFT(id: listingDetails.nftID)
        ?? panic("No item with that ID")
    let setMetadata = Birdieland_NFT.getSetMetadata(setId: nft.setId) ?? panic("no metadata found")

    return PurchaseData(
        id: listingDetails.nftID,
        name: setMetadata["name"],
        amount: listingDetails.salePrice,
        description: setMetadata["description"],
        imageURL: setMetadata["image"],
    )
}
