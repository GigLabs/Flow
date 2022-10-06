import NonFungibleToken from 0x1d7e57aa55817448
import NBA_NFT from 0x54317f5ad2f47ad3
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the NBA_NFT collection so an
// account can receive NBA_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&NBA_NFT.Collection>(from: NBA_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-NBA_NFT.createEmptyCollection(), to: NBA_NFT.CollectionStoragePath)

            // Create a public capability to the NBA_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&NBA_NFT.Collection{NBA_NFT.NBA_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                NBA_NFT.CollectionPublicPath,
                target: NBA_NFT.CollectionStoragePath
            )
        }
        // If the account already has a NBA_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&NBA_NFT.Collection{NBA_NFT.NBA_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(NBA_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the NBA_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(NBA_NFT.CollectionPublicPath)

            // Create the new public capability to the NBA_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&NBA_NFT.Collection{NBA_NFT.NBA_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                NBA_NFT.CollectionPublicPath,
                target: NBA_NFT.CollectionStoragePath
            )
        }
    }
}