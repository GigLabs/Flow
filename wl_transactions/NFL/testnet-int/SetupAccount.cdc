
import nflInt_NFT from 0x04625c28593d9408

// This transaction installs the nflInt_NFT collection so an
// account can receive nflInt_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&nflInt_NFT.Collection>(from: nflInt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-nflInt_NFT.createEmptyCollection(nftType: Type<@nflInt_NFT.NFT>()), to: nflInt_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(nflInt_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&nflInt_NFT.Collection>(nflInt_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: nflInt_NFT.CollectionPublicPath)
        }
    }
}