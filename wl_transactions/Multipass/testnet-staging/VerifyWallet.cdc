
import Multipass_NFT from 0xedd8d5484a85a86c

// This transaction installs the Multipass_NFT collection so an
// account can receive Multipass_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Multipass_NFT.Collection>(from: Multipass_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Multipass_NFT.createEmptyCollection(nftType: Type<@Multipass_NFT.NFT>()), to: Multipass_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Multipass_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Multipass_NFT.Collection>(Multipass_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Multipass_NFT.CollectionPublicPath)
        }
    }
}