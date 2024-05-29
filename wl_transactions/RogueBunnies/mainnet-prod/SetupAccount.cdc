
import RogueBunnies_NFT from 0x396646f110afb2e6

// This transaction installs the RogueBunnies_NFT collection so an
// account can receive RogueBunnies_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&RogueBunnies_NFT.Collection>(from: RogueBunnies_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-RogueBunnies_NFT.createEmptyCollection(nftType: Type<@RogueBunnies_NFT.NFT>()), to: RogueBunnies_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(RogueBunnies_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&RogueBunnies_NFT.Collection>(RogueBunnies_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: RogueBunnies_NFT.CollectionPublicPath)
        }
    }
}