
import costacos123_NFT from 0x04625c28593d9408

// This transaction installs the costacos123_NFT collection so an
// account can receive costacos123_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&costacos123_NFT.Collection>(from: costacos123_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-costacos123_NFT.createEmptyCollection(nftType: Type<@costacos123_NFT.NFT>()), to: costacos123_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(costacos123_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&costacos123_NFT.Collection>(costacos123_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: costacos123_NFT.CollectionPublicPath)
        }
    }
}