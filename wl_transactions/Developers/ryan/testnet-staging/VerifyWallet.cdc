
import ryandapper_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the ryandapper_NFT collection so an
// account can receive ryandapper_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&ryandapper_NFT.Collection>(from: ryandapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-ryandapper_NFT.createEmptyCollection(nftType: Type<@ryandapper_NFT.NFT>()), to: ryandapper_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(ryandapper_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&ryandapper_NFT.Collection>(ryandapper_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: ryandapper_NFT.CollectionPublicPath)
        }
    }
}