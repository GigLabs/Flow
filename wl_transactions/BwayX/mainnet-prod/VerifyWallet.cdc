
import BWAYX_NFT from 0xf02b15e11eb3715b

// This transaction installs the BWAYX_NFT collection so an
// account can receive BWAYX_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&BWAYX_NFT.Collection>(from: BWAYX_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-BWAYX_NFT.createEmptyCollection(nftType: Type<@BWAYX_NFT.NFT>()), to: BWAYX_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(BWAYX_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&BWAYX_NFT.Collection>(BWAYX_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: BWAYX_NFT.CollectionPublicPath)
        }
    }
}