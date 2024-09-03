
import testify_NFT from 0x36aa48b0c24b8897

// This transaction installs the testify_NFT collection so an
// account can receive testify_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&testify_NFT.Collection>(from: testify_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-testify_NFT.createEmptyCollection(nftType: Type<@testify_NFT.NFT>()), to: testify_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(testify_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&testify_NFT.Collection>(testify_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: testify_NFT.CollectionPublicPath)
        }
    }
}