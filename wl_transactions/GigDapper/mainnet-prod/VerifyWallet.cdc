import NonFungibleToken from 0x1d7e57aa55817448
import GigDapper_NFT from 0x0f8d3495fb3e8d4b
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the GigDapper_NFT collection so an
// account can receive GigDapper_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&GigDapper_NFT.Collection>(from: GigDapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-GigDapper_NFT.createEmptyCollection(), to: GigDapper_NFT.CollectionStoragePath)

            // Create a public capability to the GigDapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&GigDapper_NFT.Collection{GigDapper_NFT.GigDapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                GigDapper_NFT.CollectionPublicPath,
                target: GigDapper_NFT.CollectionStoragePath
            )
        }
        // If the account already has a GigDapper_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&GigDapper_NFT.Collection{GigDapper_NFT.GigDapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(GigDapper_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the GigDapper_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(GigDapper_NFT.CollectionPublicPath)

            // Create the new public capability to the GigDapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&GigDapper_NFT.Collection{GigDapper_NFT.GigDapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                GigDapper_NFT.CollectionPublicPath,
                target: GigDapper_NFT.CollectionStoragePath
            )
        }
    }
}