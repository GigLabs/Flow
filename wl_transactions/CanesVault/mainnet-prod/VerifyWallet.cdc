import NonFungibleToken from 0x1d7e57aa55817448
import Canes_Vault_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Canes_Vault_NFT collection so an
// account can receive Canes_Vault_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Canes_Vault_NFT.Collection>(from: Canes_Vault_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Canes_Vault_NFT.createEmptyCollection(), to: Canes_Vault_NFT.CollectionStoragePath)

            // Create a public capability to the Canes_Vault_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Canes_Vault_NFT.Collection{Canes_Vault_NFT.Canes_Vault_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Canes_Vault_NFT.CollectionPublicPath,
                target: Canes_Vault_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Canes_Vault_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Canes_Vault_NFT.Collection{Canes_Vault_NFT.Canes_Vault_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Canes_Vault_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Canes_Vault_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Canes_Vault_NFT.CollectionPublicPath)

            // Create the new public capability to the Canes_Vault_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Canes_Vault_NFT.Collection{Canes_Vault_NFT.Canes_Vault_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Canes_Vault_NFT.CollectionPublicPath,
                target: Canes_Vault_NFT.CollectionStoragePath
            )
        }
    }
}