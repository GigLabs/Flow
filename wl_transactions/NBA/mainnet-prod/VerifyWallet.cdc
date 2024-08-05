
import NBA_NFT from 0x54317f5ad2f47ad3

// This transaction installs the NBA_NFT collection so an
// account can receive NBA_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&NBA_NFT.Collection>(from: NBA_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-NBA_NFT.createEmptyCollection(nftType: Type<@NBA_NFT.NFT>()), to: NBA_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(NBA_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&NBA_NFT.Collection>(NBA_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: NBA_NFT.CollectionPublicPath)
        }
    }
}