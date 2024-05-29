
import FriendsOfFlow_NFT from 0xcee3d6cc34301ad1

// This transaction installs the FriendsOfFlow_NFT collection so an
// account can receive FriendsOfFlow_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&FriendsOfFlow_NFT.Collection>(from: FriendsOfFlow_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-FriendsOfFlow_NFT.createEmptyCollection(nftType: Type<@FriendsOfFlow_NFT.NFT>()), to: FriendsOfFlow_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(FriendsOfFlow_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&FriendsOfFlow_NFT.Collection>(FriendsOfFlow_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: FriendsOfFlow_NFT.CollectionPublicPath)
        }
    }
}