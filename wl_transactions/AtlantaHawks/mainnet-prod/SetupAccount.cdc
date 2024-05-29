
import AtlantaHawks_NFT from 0x14c2f30a9e2e923f

// This transaction installs the AtlantaHawks_NFT collection so an
// account can receive AtlantaHawks_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&AtlantaHawks_NFT.Collection>(from: AtlantaHawks_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-AtlantaHawks_NFT.createEmptyCollection(nftType: Type<@AtlantaHawks_NFT.NFT>()), to: AtlantaHawks_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(AtlantaHawks_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&AtlantaHawks_NFT.Collection>(AtlantaHawks_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: AtlantaHawks_NFT.CollectionPublicPath)
        }
    }
}