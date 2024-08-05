
import Birdieland_NFT from 0x59e3d094592231a7

// This transaction installs the Birdieland_NFT collection so an
// account can receive Birdieland_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Birdieland_NFT.Collection>(from: Birdieland_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Birdieland_NFT.createEmptyCollection(nftType: Type<@Birdieland_NFT.NFT>()), to: Birdieland_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Birdieland_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Birdieland_NFT.Collection>(Birdieland_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Birdieland_NFT.CollectionPublicPath)
        }
    }
}