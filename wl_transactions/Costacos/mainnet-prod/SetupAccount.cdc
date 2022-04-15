import NonFungibleToken from 0x1d7e57aa55817448
import Costacos_NFT from 0x329feb3ab062d289

// This transaction installs the Costacos_NFT collection so an
// account can receive Costacos_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Costacos_NFT.Collection>(from: Costacos_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Costacos_NFT.createEmptyCollection(), to: Costacos_NFT.CollectionStoragePath)

            // Create a public capability to the Costacos_NFT collection
            // that exposes the Collection interface
            signer.link<&Costacos_NFT.Collection{NonFungibleToken.CollectionPublic,Costacos_NFT.Costacos_NFTCollectionPublic}>(
                Costacos_NFT.CollectionPublicPath,
                target: Costacos_NFT.CollectionStoragePath
            )
        }
    }
}