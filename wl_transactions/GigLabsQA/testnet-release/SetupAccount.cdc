
import GigLabsQA_NFT from 0x18445fd03b683069

// This transaction installs the GigLabsQA_NFT collection so an
// account can receive GigLabsQA_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&GigLabsQA_NFT.Collection>(from: GigLabsQA_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-GigLabsQA_NFT.createEmptyCollection(nftType: Type<@GigLabsQA_NFT.NFT>()), to: GigLabsQA_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(GigLabsQA_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&GigLabsQA_NFT.Collection>(GigLabsQA_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: GigLabsQA_NFT.CollectionPublicPath)
        }
    }
}