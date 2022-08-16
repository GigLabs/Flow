import NonFungibleToken from 0x631e88ae7f1d7c20
import costacos123_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the costacos123_NFT collection so an
// account can receive costacos123_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&costacos123_NFT.Collection>(from: costacos123_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-costacos123_NFT.createEmptyCollection(), to: costacos123_NFT.CollectionStoragePath)

            // Create a public capability to the costacos123_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&costacos123_NFT.Collection{NonFungibleToken.CollectionPublic,costacos123_NFT.costacos123_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                costacos123_NFT.CollectionPublicPath,
                target: costacos123_NFT.CollectionStoragePath
            )
        }
        // If the account already has a costacos123_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&costacos123_NFT.Collection{NonFungibleToken.CollectionPublic,costacos123_NFT.costacos123_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (costacos123_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the costacos123_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(costacos123_NFT.CollectionPublicPath)

            // Create the new public capability to the costacos123_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&costacos123_NFT.Collection{NonFungibleToken.CollectionPublic,costacos123_NFT.costacos123_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                costacos123_NFT.CollectionPublicPath,
                target: costacos123_NFT.CollectionStoragePath
            )
        }
    }
}