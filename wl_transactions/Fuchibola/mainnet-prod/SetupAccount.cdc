import NonFungibleToken from 0x1d7e57aa55817448
import Fuchibola_NFT from 0xf3ee684cd0259fed

// This transaction installs the Fuchibola_NFT collection so an
// account can receive Fuchibola_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Fuchibola_NFT.Collection>(from: Fuchibola_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Fuchibola_NFT.createEmptyCollection(), to: Fuchibola_NFT.CollectionStoragePath)

            // Create a public capability to the Fuchibola_NFT collection
            // that exposes the Collection interface
            signer.link<&Fuchibola_NFT.Collection{NonFungibleToken.CollectionPublic,Fuchibola_NFT.Fuchibola_NFTCollectionPublic}>(
                Fuchibola_NFT.CollectionPublicPath,
                target: Fuchibola_NFT.CollectionStoragePath
            )
        }
    }
}