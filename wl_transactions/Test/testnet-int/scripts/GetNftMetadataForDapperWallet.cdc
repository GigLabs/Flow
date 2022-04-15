
// Get metadata for a single NFT in a owner's collection
// with the information needed to display in dapper wallet
// during a listing / sale action
import NFTStorefront from 0x94b06cfca1d8a476
import test_NFT from 0x04625c28593d9408 
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
pub fun main(address: Address, listingResourceID: UInt64): PurchaseData {
    let account = getAccount(address)
    let marketCollectionRef = account
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
            NFTStorefront.StorefrontPublicPath
        )
        .borrow()
        ?? panic("Could not borrow market collection from address")
    let saleItem = marketCollectionRef.borrowListing(listingResourceID: listingResourceID)
        ?? panic("No item with that ID")
    let listingDetails = saleItem.getDetails()!
    
    let collection = account.getCapability(test_NFT.CollectionPublicPath)
    .borrow<&{test_NFT.test_NFTCollectionPublic}>()
    ?? panic("Could not borrow a reference to the collection")
    let nft = collection.borrowtest_NFT(id: listingDetails.nftID) 
            ?? panic("Could not borrow a reference to the collection")
    let setMeta = test_NFT.getSetMetadata(setId: nft!.setId)!
        
    let purchaseData = PurchaseData(
        id: listingDetails.nftID,
        name: setMeta!["name"],
        amount: listingDetails.salePrice,
        description: setMeta!["description"],
        imageURL: setMeta!["preview"],
    )
    
    return purchaseData
}
