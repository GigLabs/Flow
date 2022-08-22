import NonFungibleToken from 0x1d7e57aa55817448
import Andbox_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Andbox_NFT collection so an
// account can receive Andbox_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Andbox_NFT.Collection>(from: Andbox_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Andbox_NFT.createEmptyCollection(), to: Andbox_NFT.CollectionStoragePath)

            // Create a public capability to the Andbox_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Andbox_NFT.Collection{Andbox_NFT.Andbox_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Andbox_NFT.CollectionPublicPath,
                target: Andbox_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Andbox_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Andbox_NFT.Collection{Andbox_NFT.Andbox_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Andbox_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Andbox_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Andbox_NFT.CollectionPublicPath)

            // Create the new public capability to the Andbox_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Andbox_NFT.Collection{Andbox_NFT.Andbox_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Andbox_NFT.CollectionPublicPath,
                target: Andbox_NFT.CollectionStoragePath
            )
        }
    }
}