import NonFungibleToken from 0x631e88ae7f1d7c20
import Dapper_NFT from 0x36b754ce392af85b
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the Dapper_NFT collection so an
// account can receive Dapper_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Dapper_NFT.Collection>(from: Dapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Dapper_NFT.createEmptyCollection(), to: Dapper_NFT.CollectionStoragePath)

            // Create a public capability to the Dapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Dapper_NFT.Collection{Dapper_NFT.Dapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Dapper_NFT.CollectionPublicPath,
                target: Dapper_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Dapper_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Dapper_NFT.Collection{Dapper_NFT.Dapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Dapper_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Dapper_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Dapper_NFT.CollectionPublicPath)

            // Create the new public capability to the Dapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Dapper_NFT.Collection{Dapper_NFT.Dapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Dapper_NFT.CollectionPublicPath,
                target: Dapper_NFT.CollectionStoragePath
            )
        }
    }
}