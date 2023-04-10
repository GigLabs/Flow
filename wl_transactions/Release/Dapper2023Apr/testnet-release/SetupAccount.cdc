import NonFungibleToken from 0x631e88ae7f1d7c20
import dapper2023apr_NFT from 0xe168d2e4bf80d3b2
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the dapper2023apr_NFT collection so an
// account can receive dapper2023apr_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&dapper2023apr_NFT.Collection>(from: dapper2023apr_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-dapper2023apr_NFT.createEmptyCollection(), to: dapper2023apr_NFT.CollectionStoragePath)

            // Create a public capability to the dapper2023apr_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&dapper2023apr_NFT.Collection{dapper2023apr_NFT.dapper2023apr_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                dapper2023apr_NFT.CollectionPublicPath,
                target: dapper2023apr_NFT.CollectionStoragePath
            )
        }
        // If the account already has a dapper2023apr_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&dapper2023apr_NFT.Collection{dapper2023apr_NFT.dapper2023apr_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(dapper2023apr_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the dapper2023apr_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(dapper2023apr_NFT.CollectionPublicPath)

            // Create the new public capability to the dapper2023apr_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&dapper2023apr_NFT.Collection{dapper2023apr_NFT.dapper2023apr_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                dapper2023apr_NFT.CollectionPublicPath,
                target: dapper2023apr_NFT.CollectionStoragePath
            )
        }
    }
}