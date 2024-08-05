
import CNN_INT_NFT from 0x04625c28593d9408

// This transaction installs the CNN_INT_NFT collection so an
// account can receive CNN_INT_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&CNN_INT_NFT.Collection>(from: CNN_INT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-CNN_INT_NFT.createEmptyCollection(nftType: Type<@CNN_INT_NFT.NFT>()), to: CNN_INT_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(CNN_INT_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&CNN_INT_NFT.Collection>(CNN_INT_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: CNN_INT_NFT.CollectionPublicPath)
        }
    }
}