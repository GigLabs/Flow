
import GigLabsDapperTake2_NFT from 0xd604d4601be3a3c5

// This transaction installs the GigLabsDapperTake2_NFT collection so an
// account can receive GigLabsDapperTake2_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&GigLabsDapperTake2_NFT.Collection>(from: GigLabsDapperTake2_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-GigLabsDapperTake2_NFT.createEmptyCollection(nftType: Type<@GigLabsDapperTake2_NFT.NFT>()), to: GigLabsDapperTake2_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(GigLabsDapperTake2_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&GigLabsDapperTake2_NFT.Collection>(GigLabsDapperTake2_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: GigLabsDapperTake2_NFT.CollectionPublicPath)
        }
    }
}