import NonFungibleToken from 0x631e88ae7f1d7c20
import Canes_Vault_Int_NFT from 0x04625c28593d9408

// This transaction installs the Canes_Vault_Int_NFT collection so an
// account can receive Canes_Vault_Int_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Canes_Vault_Int_NFT.Collection>(from: Canes_Vault_Int_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Canes_Vault_Int_NFT.createEmptyCollection(), to: Canes_Vault_Int_NFT.CollectionStoragePath)

            // Create a public capability to the Canes_Vault_Int_NFT collection
            // that exposes the Collection interface
            signer.link<&Canes_Vault_Int_NFT.Collection{NonFungibleToken.CollectionPublic,Canes_Vault_Int_NFT.Canes_Vault_Int_NFTCollectionPublic}>(
                Canes_Vault_Int_NFT.CollectionPublicPath,
                target: Canes_Vault_Int_NFT.CollectionStoragePath
            )
        }
    }
}