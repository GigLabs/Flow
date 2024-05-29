
import dapper2023apr_NFT from 0xe168d2e4bf80d3b2

// This transaction installs the dapper2023apr_NFT collection so an
// account can receive dapper2023apr_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&dapper2023apr_NFT.Collection>(from: dapper2023apr_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-dapper2023apr_NFT.createEmptyCollection(nftType: Type<@dapper2023apr_NFT.NFT>()), to: dapper2023apr_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(dapper2023apr_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&dapper2023apr_NFT.Collection>(dapper2023apr_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: dapper2023apr_NFT.CollectionPublicPath)
        }
    }
}