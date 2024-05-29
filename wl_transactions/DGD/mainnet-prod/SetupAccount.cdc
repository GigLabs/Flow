
import DGD_NFT from 0x329feb3ab062d289

// This transaction installs the DGD_NFT collection so an
// account can receive DGD_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&DGD_NFT.Collection>(from: DGD_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-DGD_NFT.createEmptyCollection(nftType: Type<@DGD_NFT.NFT>()), to: DGD_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(DGD_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&DGD_NFT.Collection>(DGD_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: DGD_NFT.CollectionPublicPath)
        }
    }
}