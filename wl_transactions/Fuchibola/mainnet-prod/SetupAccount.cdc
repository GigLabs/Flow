
import Fuchibola_NFT from 0xf3ee684cd0259fed

// This transaction installs the Fuchibola_NFT collection so an
// account can receive Fuchibola_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Fuchibola_NFT.Collection>(from: Fuchibola_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Fuchibola_NFT.createEmptyCollection(nftType: Type<@Fuchibola_NFT.NFT>()), to: Fuchibola_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Fuchibola_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Fuchibola_NFT.Collection>(Fuchibola_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Fuchibola_NFT.CollectionPublicPath)
        }
    }
}