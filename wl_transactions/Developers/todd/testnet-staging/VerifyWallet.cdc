
import ToddDapper_NFT from 0x074bae238bc6b419

// This transaction installs the ToddDapper_NFT collection so an
// account can receive ToddDapper_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&ToddDapper_NFT.Collection>(from: ToddDapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-ToddDapper_NFT.createEmptyCollection(nftType: Type<@ToddDapper_NFT.NFT>()), to: ToddDapper_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(ToddDapper_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&ToddDapper_NFT.Collection>(ToddDapper_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: ToddDapper_NFT.CollectionPublicPath)
        }
    }
}