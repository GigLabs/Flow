
import RaceDay_NFT from 0x329feb3ab062d289

// This transaction installs the RaceDay_NFT collection so an
// account can receive RaceDay_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&RaceDay_NFT.Collection>(from: RaceDay_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-RaceDay_NFT.createEmptyCollection(nftType: Type<@RaceDay_NFT.NFT>()), to: RaceDay_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(RaceDay_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&RaceDay_NFT.Collection>(RaceDay_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: RaceDay_NFT.CollectionPublicPath)
        }
    }
}