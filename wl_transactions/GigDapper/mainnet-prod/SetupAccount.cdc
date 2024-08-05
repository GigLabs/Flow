
import GigDapper_NFT from 0x0f8d3495fb3e8d4b

// This transaction installs the GigDapper_NFT collection so an
// account can receive GigDapper_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&GigDapper_NFT.Collection>(from: GigDapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-GigDapper_NFT.createEmptyCollection(nftType: Type<@GigDapper_NFT.NFT>()), to: GigDapper_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(GigDapper_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&GigDapper_NFT.Collection>(GigDapper_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: GigDapper_NFT.CollectionPublicPath)
        }
    }
}