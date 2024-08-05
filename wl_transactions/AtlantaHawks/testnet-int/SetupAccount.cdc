
import atlantahawks_NFT from 0x04625c28593d9408

// This transaction installs the atlantahawks_NFT collection so an
// account can receive atlantahawks_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&atlantahawks_NFT.Collection>(from: atlantahawks_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-atlantahawks_NFT.createEmptyCollection(nftType: Type<@atlantahawks_NFT.NFT>()), to: atlantahawks_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(atlantahawks_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&atlantahawks_NFT.Collection>(atlantahawks_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: atlantahawks_NFT.CollectionPublicPath)
        }
    }
}