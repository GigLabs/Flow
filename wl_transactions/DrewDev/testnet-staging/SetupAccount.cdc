import NonFungibleToken from 0x631e88ae7f1d7c20
import drewdapper_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the drewdapper_NFT collection so an
// account can receive drewdapper_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&drewdapper_NFT.Collection>(from: drewdapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-drewdapper_NFT.createEmptyCollection(), to: drewdapper_NFT.CollectionStoragePath)

            // Create a public capability to the drewdapper_NFT collection
            // that exposes the Collection interface
            signer.link<&drewdapper_NFT.Collection{NonFungibleToken.CollectionPublic,drewdapper_NFT.drewdapper_NFTCollectionPublic}>(
                drewdapper_NFT.CollectionPublicPath,
                target: drewdapper_NFT.CollectionStoragePath
            )
        }
    }
}