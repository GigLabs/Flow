import NonFungibleToken from 0x1d7e57aa55817448
import AtlantaHawks_NFT from 0x14c2f30a9e2e923f
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the AtlantaHawks_NFT collection so an
// account can receive AtlantaHawks_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&AtlantaHawks_NFT.Collection>(from: AtlantaHawks_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-AtlantaHawks_NFT.createEmptyCollection(), to: AtlantaHawks_NFT.CollectionStoragePath)

            // Create a public capability to the AtlantaHawks_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&AtlantaHawks_NFT.Collection{AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                AtlantaHawks_NFT.CollectionPublicPath,
                target: AtlantaHawks_NFT.CollectionStoragePath
            )
        }
        // If the account already has a AtlantaHawks_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&AtlantaHawks_NFT.Collection{AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(AtlantaHawks_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the AtlantaHawks_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(AtlantaHawks_NFT.CollectionPublicPath)

            // Create the new public capability to the AtlantaHawks_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&AtlantaHawks_NFT.Collection{AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                AtlantaHawks_NFT.CollectionPublicPath,
                target: AtlantaHawks_NFT.CollectionStoragePath
            )
        }
    }
}