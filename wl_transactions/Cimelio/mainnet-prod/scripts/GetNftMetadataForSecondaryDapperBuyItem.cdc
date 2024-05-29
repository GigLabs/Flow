
// Get metadata for a single NFT in a owner's collection
// needed to display the NFT in dapper wallet
// during the secondary purchase of an NFT
import Cimelio_NFT from 0x2c9de937c319468d
import NFTStorefront from 0x4eb8a10cb9f87357

access(all) struct PurchaseData {
    access(all) let id: UInt64
    access(all) let name: String?
    access(all) let amount: UFix64
    access(all) let description: String?
    access(all) let imageURL: String?

    init(id: UInt64, name: String?, amount: UFix64, description: String?, imageURL: String?) {
        self.id = id
        self.name = name
        self.amount = amount
        self.description = description
        self.imageURL = imageURL
    }
}

access(all) fun main(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64): PurchaseData {
    let acct = getAccount(storefrontAddress)

    // Get the storefront reference from the seller
    let storefront = acct.capabilities.borrow<&NFTStorefront.Storefront>(
            NFTStorefront.StorefrontPublicPath)
            ?? panic("Could not borrow Storefront from provided address")

    // Get the listing by ID from the storefront
    let listing = storefront.borrowListing(listingResourceID: listingResourceID)
        ?? panic("No item with that ID")
    let listingDetails = listing.getDetails()

    // Get the NFT and use it to fetch set metadata
    let collectionRef = acct.capabilities.borrow<&Cimelio_NFT.Collection>(Cimelio_NFT.CollectionPublicPath)
        ?? panic("Could not borrow collection from address")
    let nft = collectionRef.borrowCimelio_NFT(id: listingDetails.nftID)
        ?? panic("No item with that ID")
    let setMetadata = Cimelio_NFT.getSetMetadata(setId: nft.setId) ?? panic("no metadata found")

    return PurchaseData(
        id: listingDetails.nftID,
        name: setMetadata["name"],
        amount: listingDetails.salePrice,
        description: setMetadata["description"],
        imageURL: setMetadata["image"],
    )
}
