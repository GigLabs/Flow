
import fuchibola_NFT from 0x04625c28593d9408

// This transaction installs the fuchibola_NFT collection so an
// account can receive fuchibola_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&fuchibola_NFT.Collection>(from: fuchibola_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-fuchibola_NFT.createEmptyCollection(nftType: Type<@fuchibola_NFT.NFT>()), to: fuchibola_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(fuchibola_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&fuchibola_NFT.Collection>(fuchibola_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: fuchibola_NFT.CollectionPublicPath)
        }
    }
}