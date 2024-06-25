import NonFungibleToken from 0x631e88ae7f1d7c20
import atlantahawks_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the atlantahawks_NFT collection so an
// account can receive atlantahawks_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&atlantahawks_NFT.Collection>(from: atlantahawks_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-atlantahawks_NFT.createEmptyCollection(), to: atlantahawks_NFT.CollectionStoragePath)

            // Create a public capability to the atlantahawks_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&atlantahawks_NFT.Collection{atlantahawks_NFT.atlantahawks_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                atlantahawks_NFT.CollectionPublicPath,
                target: atlantahawks_NFT.CollectionStoragePath
            )
        }
        // If the account already has a atlantahawks_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&atlantahawks_NFT.Collection{atlantahawks_NFT.atlantahawks_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(atlantahawks_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the atlantahawks_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(atlantahawks_NFT.CollectionPublicPath)

            // Create the new public capability to the atlantahawks_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&atlantahawks_NFT.Collection{atlantahawks_NFT.atlantahawks_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                atlantahawks_NFT.CollectionPublicPath,
                target: atlantahawks_NFT.CollectionStoragePath
            )
        }
    }
}