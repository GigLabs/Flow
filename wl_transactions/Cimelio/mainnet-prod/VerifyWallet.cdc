
import Cimelio_NFT from 0x2c9de937c319468d

// This transaction installs the Cimelio_NFT collection so an
// account can receive Cimelio_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Cimelio_NFT.Collection>(from: Cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Cimelio_NFT.createEmptyCollection(nftType: Type<@Cimelio_NFT.NFT>()), to: Cimelio_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Cimelio_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Cimelio_NFT.Collection>(Cimelio_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Cimelio_NFT.CollectionPublicPath)
        }
    }
}