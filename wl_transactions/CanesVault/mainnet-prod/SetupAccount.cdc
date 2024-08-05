
import Canes_Vault_NFT from 0x329feb3ab062d289

// This transaction installs the Canes_Vault_NFT collection so an
// account can receive Canes_Vault_NFT NFTs 

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        // If the account doesn't already have a collection
        if signer.storage.borrow<&Canes_Vault_NFT.Collection>(from: Canes_Vault_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.storage.save(<-Canes_Vault_NFT.createEmptyCollection(nftType: Type<@Canes_Vault_NFT.NFT>()), to: Canes_Vault_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(Canes_Vault_NFT.CollectionPublicPath)
            let collectionCap = signer.capabilities.storage.issue<&Canes_Vault_NFT.Collection>(Canes_Vault_NFT.CollectionStoragePath)
            signer.capabilities.publish(collectionCap, at: Canes_Vault_NFT.CollectionPublicPath)
        }
    }
}