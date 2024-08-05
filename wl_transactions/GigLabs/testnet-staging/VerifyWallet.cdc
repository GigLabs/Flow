
import giglabs_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the giglabs_NFT collection so an
// account can receive giglabs_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&giglabs_NFT.Collection>(from: giglabs_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-giglabs_NFT.createEmptyCollection(nftType: Type<@giglabs_NFT.NFT>()), to: giglabs_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(giglabs_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&giglabs_NFT.Collection>(giglabs_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: giglabs_NFT.CollectionPublicPath)
        }
    }
}