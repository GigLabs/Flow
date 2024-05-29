
import dapperrelease2point0_NFT from 0xd0c7d5711cb0dc51

// This transaction installs the dapperrelease2point0_NFT collection so an
// account can receive dapperrelease2point0_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&dapperrelease2point0_NFT.Collection>(from: dapperrelease2point0_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-dapperrelease2point0_NFT.createEmptyCollection(nftType: Type<@dapperrelease2point0_NFT.NFT>()), to: dapperrelease2point0_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(dapperrelease2point0_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&dapperrelease2point0_NFT.Collection>(dapperrelease2point0_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: dapperrelease2point0_NFT.CollectionPublicPath)
        }
    }
}