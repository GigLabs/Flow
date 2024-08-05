
import friendsOfFlow_NFT from 0x04625c28593d9408

// This transaction installs the friendsOfFlow_NFT collection so an
// account can receive friendsOfFlow_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&friendsOfFlow_NFT.Collection>(from: friendsOfFlow_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-friendsOfFlow_NFT.createEmptyCollection(nftType: Type<@friendsOfFlow_NFT.NFT>()), to: friendsOfFlow_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(friendsOfFlow_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&friendsOfFlow_NFT.Collection>(friendsOfFlow_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: friendsOfFlow_NFT.CollectionPublicPath)
        }
    }
}