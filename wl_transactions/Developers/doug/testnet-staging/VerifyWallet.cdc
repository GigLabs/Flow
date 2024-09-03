
import podunks23_NFT from 0xe881728fa66efd3b

// This transaction installs the podunks23_NFT collection so an
// account can receive podunks23_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&podunks23_NFT.Collection>(from: podunks23_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-podunks23_NFT.createEmptyCollection(nftType: Type<@podunks23_NFT.NFT>()), to: podunks23_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(podunks23_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&podunks23_NFT.Collection>(podunks23_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: podunks23_NFT.CollectionPublicPath)
        }
    }
}