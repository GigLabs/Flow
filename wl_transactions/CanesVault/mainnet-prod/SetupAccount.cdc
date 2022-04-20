import NonFungibleToken from 0x1d7e57aa55817448
import CanesVault_NFT from 0x329feb3ab062d289

// This transaction installs the CanesVault_NFT collection so an
// account can receive CanesVault_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&CanesVault_NFT.Collection>(from: CanesVault_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-CanesVault_NFT.createEmptyCollection(), to: CanesVault_NFT.CollectionStoragePath)

            // Create a public capability to the CanesVault_NFT collection
            // that exposes the Collection interface
            signer.link<&CanesVault_NFT.Collection{NonFungibleToken.CollectionPublic,CanesVault_NFT.CanesVault_NFTCollectionPublic}>(
                CanesVault_NFT.CollectionPublicPath,
                target: CanesVault_NFT.CollectionStoragePath
            )
        }
    }
}