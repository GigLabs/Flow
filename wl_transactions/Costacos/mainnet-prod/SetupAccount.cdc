
import Costacos_NFT from 0x329feb3ab062d289

// This transaction installs the Costacos_NFT collection so an
// account can receive Costacos_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Costacos_NFT.Collection>(from: Costacos_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Costacos_NFT.createEmptyCollection(nftType: Type<@Costacos_NFT.NFT>()), to: Costacos_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Costacos_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Costacos_NFT.Collection>(Costacos_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Costacos_NFT.CollectionPublicPath)
        }
    }
}