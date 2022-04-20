import NonFungibleToken from 0x1d7e57aa55817448
import Canes_Vault_NFT from 0x329feb3ab062d289

// This transaction installs the Canes_Vault_NFT collection so an
// account can receive Canes_Vault_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Canes_Vault_NFT.Collection>(from: Canes_Vault_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Canes_Vault_NFT.createEmptyCollection(), to: Canes_Vault_NFT.CollectionStoragePath)

            // Create a public capability to the Canes_Vault_NFT collection
            // that exposes the Collection interface
            signer.link<&Canes_Vault_NFT.Collection{NonFungibleToken.CollectionPublic,Canes_Vault_NFT.Canes_Vault_NFTCollectionPublic}>(
                Canes_Vault_NFT.CollectionPublicPath,
                target: Canes_Vault_NFT.CollectionStoragePath
            )
        }
    }
}