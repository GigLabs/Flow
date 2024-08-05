
import cimelio_NFT from 0x04625c28593d9408

// This transaction installs the cimelio_NFT collection so an
// account can receive cimelio_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&cimelio_NFT.Collection>(from: cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-cimelio_NFT.createEmptyCollection(nftType: Type<@cimelio_NFT.NFT>()), to: cimelio_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(cimelio_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&cimelio_NFT.Collection>(cimelio_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: cimelio_NFT.CollectionPublicPath)
        }
    }
}