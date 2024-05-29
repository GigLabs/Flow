
import roguebunnies_NFT from 0x04625c28593d9408

// This transaction installs the roguebunnies_NFT collection so an
// account can receive roguebunnies_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&roguebunnies_NFT.Collection>(from: roguebunnies_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-roguebunnies_NFT.createEmptyCollection(nftType: Type<@roguebunnies_NFT.NFT>()), to: roguebunnies_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(roguebunnies_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&roguebunnies_NFT.Collection>(roguebunnies_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: roguebunnies_NFT.CollectionPublicPath)
        }
    }
}