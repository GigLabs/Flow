import NonFungibleToken from 0x1d7e57aa55817448
import AtlantaHawks_NFT from 14c2f30a9e2e923f

// This transaction installs the AtlantaHawks_NFT collection so an
// account can receive AtlantaHawks_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&AtlantaHawks_NFT.Collection>(from: AtlantaHawks_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-AtlantaHawks_NFT.createEmptyCollection(), to: AtlantaHawks_NFT.CollectionStoragePath)

            // Create a public capability to the AtlantaHawks_NFT collection
            // that exposes the Collection interface
            signer.link<&AtlantaHawks_NFT.Collection{NonFungibleToken.CollectionPublic,AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic}>(
                AtlantaHawks_NFT.CollectionPublicPath,
                target: AtlantaHawks_NFT.CollectionStoragePath
            )
        }
    }
}