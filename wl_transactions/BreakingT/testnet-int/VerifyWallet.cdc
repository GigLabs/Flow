import NonFungibleToken from 0x631e88ae7f1d7c20
import breakingt_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the breakingt_NFT collection so an
// account can receive breakingt_NFT NFTs 

transaction(userId: UInt64) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&breakingt_NFT.Collection>(from: breakingt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-breakingt_NFT.createEmptyCollection(), to: breakingt_NFT.CollectionStoragePath)

            // Create a public capability to the breakingt_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&breakingt_NFT.Collection{breakingt_NFT.breakingt_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                breakingt_NFT.CollectionPublicPath,
                target: breakingt_NFT.CollectionStoragePath
            )
        }
        // If the account already has a breakingt_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&breakingt_NFT.Collection{breakingt_NFT.breakingt_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(breakingt_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the breakingt_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(breakingt_NFT.CollectionPublicPath)

            // Create the new public capability to the breakingt_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&breakingt_NFT.Collection{breakingt_NFT.breakingt_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                breakingt_NFT.CollectionPublicPath,
                target: breakingt_NFT.CollectionStoragePath
            )
        }
    }
}