
import CNN_NFT from 0x329feb3ab062d289

// This transaction installs the CNN_NFT collection so an
// account can receive CNN_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&CNN_NFT.Collection>(from: CNN_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-CNN_NFT.createEmptyCollection(nftType: Type<@CNN_NFT.NFT>()), to: CNN_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(CNN_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&CNN_NFT.Collection>(CNN_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: CNN_NFT.CollectionPublicPath)
        }
    }
}