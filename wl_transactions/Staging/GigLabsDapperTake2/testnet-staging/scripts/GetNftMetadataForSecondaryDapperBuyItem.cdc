
// Get metadata for a single NFT in a owner's collection
// needed to display the NFT in dapper wallet
// during the secondary purchase of an NFT
import GigLabsDapperTake2_NFT from 0xd604d4601be3a3c5
import NFTStorefront from 0x94b06cfca1d8a476

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

pub fun main(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64): PurchaseData {
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
    let collectionRef = acct.getCapability(GigLabsDapperTake2_NFT.CollectionPublicPath)
        .borrow<&{GigLabsDapperTake2_NFT.GigLabsDapperTake2_NFTCollectionPublic}>()
        ?? panic("Could not borrow collection from address")
    let nft = collectionRef.borrowGigLabsDapperTake2_NFT(id: listingDetails.nftID)
        ?? panic("No item with that ID")
    let setMetadata = GigLabsDapperTake2_NFT.getSetMetadata(setId: nft.setId) ?? panic("no metadata found")

    return PurchaseData(
        id: listingDetails.nftID,
        name: setMetadata["name"],
        amount: listingDetails.salePrice,
        description: setMetadata["description"],
        imageURL: setMetadata["image"],
    )
}
