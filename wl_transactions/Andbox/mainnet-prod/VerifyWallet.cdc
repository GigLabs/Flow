
import Andbox_NFT from 0x329feb3ab062d289

// This transaction installs the Andbox_NFT collection so an
// account can receive Andbox_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Andbox_NFT.Collection>(from: Andbox_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Andbox_NFT.createEmptyCollection(nftType: Type<@Andbox_NFT.NFT>()), to: Andbox_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Andbox_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Andbox_NFT.Collection>(Andbox_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Andbox_NFT.CollectionPublicPath)
        }
    }
}