import NonFungibleToken from 0x631e88ae7f1d7c20
import nba_NFT from 0x04625c28593d9408
import MetadataViews from 0x9b053ed2bd3e7339

// This transaction installs the nba_NFT collection so an
// account can receive nba_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&nba_NFT.Collection>(from: nba_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-nba_NFT.createEmptyCollection(), to: nba_NFT.CollectionStoragePath)

            // Create a public capability to the nba_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                nba_NFT.CollectionPublicPath,
                target: nba_NFT.CollectionStoragePath
            )
        }
        // If the account already has a nba_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (nba_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the nba_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(nba_NFT.CollectionPublicPath)

            // Create the new public capability to the nba_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                nba_NFT.CollectionPublicPath,
                target: nba_NFT.CollectionStoragePath
            )
        }
    }
}