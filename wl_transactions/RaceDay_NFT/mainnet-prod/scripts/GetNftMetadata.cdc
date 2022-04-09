
// Get metadata for a single NFT in a owner's collection

//import NonFungibleToken contract
import RaceDay_NFT from 0x329feb3ab062d289

// This script reads metadata from an NFT in an owner's collection
pub fun main(account: Address, tokenId: UInt64): {String: String}? {

    // Get both public account objects
    let account = getAccount(account);
 
    // Find the public Receiver capability for their Collections
    let acctCapability = account.getCapability(RaceDay_NFT.CollectionPublicPath)!

    // Borrow references from the capabilities
    let collectionBorrow = acctCapability.borrow<&{RaceDay_NFT.RaceDay_NFTCollectionPublic}>()
        ?? panic("Could not borrow account receiver reference")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionBorrow.borrowRaceDay_NFT(id: tokenId)
        ?? panic("No such tokenId in that collection")
    
    var nftMetadata = RaceDay_NFT.getSetMetadata(setId: nft.setId)
        ?? panic("Set doesn't exist")
 
    let seriesId = RaceDay_NFT.getSetSeriesId(setId: nft.setId)
        ?? panic("Set doesn't exist")

    let seriesMetadata = RaceDay_NFT.getSeriesMetadata(seriesId: seriesId)
        ?? panic("Series doesn't exist")

    let nftEditions = RaceDay_NFT.getSetMaxEditions(setId: nft.setId)
        ?? panic("Set doesn't exist")

    // Is there a better way to do concat two dictionaries?
    let seriesMetadataKeys = seriesMetadata.keys
    let seriesMetadataValues = seriesMetadata.values
    var i = 0
    while i < seriesMetadata.length {
        nftMetadata.insert(key: seriesMetadataKeys[i], seriesMetadataValues[i])
        i = i + 1
    }
    nftMetadata.insert(key: "series_id", seriesId.toString())
    nftMetadata.insert(key: "set_id", nft.setId.toString())
    nftMetadata.insert(key: "edition", nft.editionNum.toString())
    nftMetadata.insert(key: "max_editions", nftEditions.toString())

    return nftMetadata
}
//