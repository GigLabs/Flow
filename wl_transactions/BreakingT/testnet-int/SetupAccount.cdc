
import BreakingT_NFT from 0x04625c28593d9408

// This transaction installs the BreakingT_NFT collection so an
// account can receive BreakingT_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-BreakingT_NFT.createEmptyCollection(nftType: Type<@BreakingT_NFT.NFT>()), to: BreakingT_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(BreakingT_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&BreakingT_NFT.Collection>(BreakingT_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: BreakingT_NFT.CollectionPublicPath)
        }
    }
}