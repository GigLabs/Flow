
import nba_NFT from 0x04625c28593d9408

// This transaction installs the nba_NFT collection so an
// account can receive nba_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&nba_NFT.Collection>(from: nba_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-nba_NFT.createEmptyCollection(nftType: Type<@nba_NFT.NFT>()), to: nba_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(nba_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&nba_NFT.Collection>(nba_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: nba_NFT.CollectionPublicPath)
        }
    }
}