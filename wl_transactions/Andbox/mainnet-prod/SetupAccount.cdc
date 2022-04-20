import NonFungibleToken from 0x1d7e57aa55817448
import Andbox_NFT from 0x329feb3ab062d289

// This transaction installs the Andbox_NFT collection so an
// account can receive Andbox_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Andbox_NFT.Collection>(from: Andbox_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Andbox_NFT.createEmptyCollection(), to: Andbox_NFT.CollectionStoragePath)

            // Create a public capability to the Andbox_NFT collection
            // that exposes the Collection interface
            signer.link<&Andbox_NFT.Collection{NonFungibleToken.CollectionPublic,Andbox_NFT.Andbox_NFTCollectionPublic}>(
                Andbox_NFT.CollectionPublicPath,
                target: Andbox_NFT.CollectionStoragePath
            )
        }
    }
}