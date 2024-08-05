
import Dapper_NFT from 0x36b754ce392af85b

// This transaction installs the Dapper_NFT collection so an
// account can receive Dapper_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Dapper_NFT.Collection>(from: Dapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Dapper_NFT.createEmptyCollection(nftType: Type<@Dapper_NFT.NFT>()), to: Dapper_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Dapper_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Dapper_NFT.Collection>(Dapper_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Dapper_NFT.CollectionPublicPath)
        }
    }
}