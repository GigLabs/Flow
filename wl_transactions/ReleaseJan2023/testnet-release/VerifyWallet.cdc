
import releasejan2023_NFT from 0x5d2efb448f701c35

// This transaction installs the releasejan2023_NFT collection so an
// account can receive releasejan2023_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&releasejan2023_NFT.Collection>(from: releasejan2023_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-releasejan2023_NFT.createEmptyCollection(nftType: Type<@releasejan2023_NFT.NFT>()), to: releasejan2023_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(releasejan2023_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&releasejan2023_NFT.Collection>(releasejan2023_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: releasejan2023_NFT.CollectionPublicPath)
        }
    }
}