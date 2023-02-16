import NonFungibleToken from 0x631e88ae7f1d7c20
import BreakingT_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the BreakingT_NFT collection so an
// account can receive BreakingT_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-BreakingT_NFT.createEmptyCollection(), to: BreakingT_NFT.CollectionStoragePath)

            // Create a public capability to the BreakingT_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&BreakingT_NFT.Collection{BreakingT_NFT.BreakingT_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                BreakingT_NFT.CollectionPublicPath,
                target: BreakingT_NFT.CollectionStoragePath
            )
        }
        // If the account already has a BreakingT_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&BreakingT_NFT.Collection{BreakingT_NFT.BreakingT_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(BreakingT_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the BreakingT_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(BreakingT_NFT.CollectionPublicPath)

            // Create the new public capability to the BreakingT_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&BreakingT_NFT.Collection{BreakingT_NFT.BreakingT_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                BreakingT_NFT.CollectionPublicPath,
                target: BreakingT_NFT.CollectionStoragePath
            )
        }
    }
}