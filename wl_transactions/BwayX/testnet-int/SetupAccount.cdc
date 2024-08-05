
import bwayx_NFT from 0x477638bc70a9341e

// This transaction installs the bwayx_NFT collection so an
// account can receive bwayx_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&bwayx_NFT.Collection>(from: bwayx_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-bwayx_NFT.createEmptyCollection(nftType: Type<@bwayx_NFT.NFT>()), to: bwayx_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(bwayx_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&bwayx_NFT.Collection>(bwayx_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: bwayx_NFT.CollectionPublicPath)
        }
    }
}