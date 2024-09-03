
import daptik_NFT from 0x18f64cc2a32091a3

// This transaction installs the daptik_NFT collection so an
// account can receive daptik_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&daptik_NFT.Collection>(from: daptik_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-daptik_NFT.createEmptyCollection(nftType: Type<@daptik_NFT.NFT>()), to: daptik_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(daptik_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&daptik_NFT.Collection>(daptik_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: daptik_NFT.CollectionPublicPath)
        }
    }
}