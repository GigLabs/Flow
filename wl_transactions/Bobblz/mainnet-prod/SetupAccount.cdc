
import Bobblz_NFT from 0xd45e2bd9a3d5003b

// This transaction installs the Bobblz_NFT collection so an
// account can receive Bobblz_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Bobblz_NFT.Collection>(from: Bobblz_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Bobblz_NFT.createEmptyCollection(nftType: Type<@Bobblz_NFT.NFT>()), to: Bobblz_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Bobblz_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Bobblz_NFT.Collection>(Bobblz_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Bobblz_NFT.CollectionPublicPath)
        }
    }
}