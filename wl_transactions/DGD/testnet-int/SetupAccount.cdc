
import dgd_NFT from 0x04625c28593d9408

// This transaction installs the dgd_NFT collection so an
// account can receive dgd_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&dgd_NFT.Collection>(from: dgd_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-dgd_NFT.createEmptyCollection(nftType: Type<@dgd_NFT.NFT>()), to: dgd_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(dgd_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&dgd_NFT.Collection>(dgd_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: dgd_NFT.CollectionPublicPath)
        }
    }
}