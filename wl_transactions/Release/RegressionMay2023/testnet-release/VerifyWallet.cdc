
import regressionmay2023_NFT from 0xf1f796c8275ba052

// This transaction installs the regressionmay2023_NFT collection so an
// account can receive regressionmay2023_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&regressionmay2023_NFT.Collection>(from: regressionmay2023_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-regressionmay2023_NFT.createEmptyCollection(nftType: Type<@regressionmay2023_NFT.NFT>()), to: regressionmay2023_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(regressionmay2023_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&regressionmay2023_NFT.Collection>(regressionmay2023_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: regressionmay2023_NFT.CollectionPublicPath)
        }
    }
}