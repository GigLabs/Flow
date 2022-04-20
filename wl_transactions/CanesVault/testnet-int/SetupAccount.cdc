import NonFungibleToken from 0x631e88ae7f1d7c20
import canesvault_NFT from 0x04625c28593d9408

// This transaction installs the canesvault_NFT collection so an
// account can receive canesvault_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&canesvault_NFT.Collection>(from: canesvault_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-canesvault_NFT.createEmptyCollection(), to: canesvault_NFT.CollectionStoragePath)

            // Create a public capability to the canesvault_NFT collection
            // that exposes the Collection interface
            signer.link<&canesvault_NFT.Collection{NonFungibleToken.CollectionPublic,canesvault_NFT.canesvault_NFTCollectionPublic}>(
                canesvault_NFT.CollectionPublicPath,
                target: canesvault_NFT.CollectionStoragePath
            )
        }
    }
}