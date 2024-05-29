
import UFC_NFT from 0x329feb3ab062d289

// This transaction installs the UFC_NFT collection so an
// account can receive UFC_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&UFC_NFT.Collection>(from: UFC_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-UFC_NFT.createEmptyCollection(nftType: Type<@UFC_NFT.NFT>()), to: UFC_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(UFC_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&UFC_NFT.Collection>(UFC_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: UFC_NFT.CollectionPublicPath)
        }
    }
}