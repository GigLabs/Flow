
import bobblz_NFT from 0x04625c28593d9408

// This transaction installs the bobblz_NFT collection so an
// account can receive bobblz_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&bobblz_NFT.Collection>(from: bobblz_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-bobblz_NFT.createEmptyCollection(nftType: Type<@bobblz_NFT.NFT>()), to: bobblz_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(bobblz_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&bobblz_NFT.Collection>(bobblz_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: bobblz_NFT.CollectionPublicPath)
        }
    }
}