
import DapPen_NFT from 0x1df9c41532276279

// This transaction installs the DapPen_NFT collection so an
// account can receive DapPen_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&DapPen_NFT.Collection>(from: DapPen_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-DapPen_NFT.createEmptyCollection(nftType: Type<@DapPen_NFT.NFT>()), to: DapPen_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(DapPen_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&DapPen_NFT.Collection>(DapPen_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: DapPen_NFT.CollectionPublicPath)
        }
    }
}