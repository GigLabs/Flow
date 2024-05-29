
import drewdapper_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the drewdapper_NFT collection so an
// account can receive drewdapper_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&drewdapper_NFT.Collection>(from: drewdapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-drewdapper_NFT.createEmptyCollection(nftType: Type<@drewdapper_NFT.NFT>()), to: drewdapper_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(drewdapper_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&drewdapper_NFT.Collection>(drewdapper_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: drewdapper_NFT.CollectionPublicPath)
        }
    }
}