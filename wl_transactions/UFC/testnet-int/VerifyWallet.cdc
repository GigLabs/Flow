
import ufcInt_NFT from 0x04625c28593d9408

// This transaction installs the ufcInt_NFT collection so an
// account can receive ufcInt_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&ufcInt_NFT.Collection>(from: ufcInt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-ufcInt_NFT.createEmptyCollection(nftType: Type<@ufcInt_NFT.NFT>()), to: ufcInt_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(ufcInt_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&ufcInt_NFT.Collection>(ufcInt_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: ufcInt_NFT.CollectionPublicPath)
        }
    }
}