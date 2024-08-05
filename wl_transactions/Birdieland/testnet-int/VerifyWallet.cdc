
import izon_NFT from 0x04625c28593d9408

// This transaction installs the izon_NFT collection so an
// account can receive izon_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&izon_NFT.Collection>(from: izon_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-izon_NFT.createEmptyCollection(nftType: Type<@izon_NFT.NFT>()), to: izon_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(izon_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&izon_NFT.Collection>(izon_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: izon_NFT.CollectionPublicPath)
        }
    }
}