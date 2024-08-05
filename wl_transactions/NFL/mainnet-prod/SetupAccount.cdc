
import NFL_NFT from 0x329feb3ab062d289

// This transaction installs the NFL_NFT collection so an
// account can receive NFL_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&NFL_NFT.Collection>(from: NFL_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-NFL_NFT.createEmptyCollection(nftType: Type<@NFL_NFT.NFT>()), to: NFL_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(NFL_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&NFL_NFT.Collection>(NFL_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: NFL_NFT.CollectionPublicPath)
        }
    }
}