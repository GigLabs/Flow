import NonFungibleToken from 0x631e88ae7f1d7c20
import AndBoxINT_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the AndBoxINT_NFT collection so an
// account can receive AndBoxINT_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&AndBoxINT_NFT.Collection>(from: AndBoxINT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-AndBoxINT_NFT.createEmptyCollection(), to: AndBoxINT_NFT.CollectionStoragePath)

            // Create a public capability to the AndBoxINT_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&AndBoxINT_NFT.Collection{NonFungibleToken.CollectionPublic,AndBoxINT_NFT.AndBoxINT_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                AndBoxINT_NFT.CollectionPublicPath,
                target: AndBoxINT_NFT.CollectionStoragePath
            )
        }
        // If the account already has a AndBoxINT_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&AndBoxINT_NFT.Collection{NonFungibleToken.CollectionPublic,AndBoxINT_NFT.AndBoxINT_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (AndBoxINT_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the AndBoxINT_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(AndBoxINT_NFT.CollectionPublicPath)

            // Create the new public capability to the AndBoxINT_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&AndBoxINT_NFT.Collection{NonFungibleToken.CollectionPublic,AndBoxINT_NFT.AndBoxINT_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                AndBoxINT_NFT.CollectionPublicPath,
                target: AndBoxINT_NFT.CollectionStoragePath
            )
        }
    }
}