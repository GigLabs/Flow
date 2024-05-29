
import AndBoxINT_NFT from 0x04625c28593d9408

// This transaction installs the AndBoxINT_NFT collection so an
// account can receive AndBoxINT_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&AndBoxINT_NFT.Collection>(from: AndBoxINT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-AndBoxINT_NFT.createEmptyCollection(nftType: Type<@AndBoxINT_NFT.NFT>()), to: AndBoxINT_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(AndBoxINT_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&AndBoxINT_NFT.Collection>(AndBoxINT_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: AndBoxINT_NFT.CollectionPublicPath)
        }
    }
}