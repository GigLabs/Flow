import NonFungibleToken from 0x631e88ae7f1d7c20
import roguebunnies_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the roguebunnies_NFT collection so an
// account can receive roguebunnies_NFT NFTs 

transaction(userId: UInt64) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&roguebunnies_NFT.Collection>(from: roguebunnies_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-roguebunnies_NFT.createEmptyCollection(), to: roguebunnies_NFT.CollectionStoragePath)

            // Create a public capability to the roguebunnies_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&roguebunnies_NFT.Collection{roguebunnies_NFT.roguebunnies_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                roguebunnies_NFT.CollectionPublicPath,
                target: roguebunnies_NFT.CollectionStoragePath
            )
        }
        // If the account already has a roguebunnies_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&roguebunnies_NFT.Collection{roguebunnies_NFT.roguebunnies_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(roguebunnies_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the roguebunnies_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(roguebunnies_NFT.CollectionPublicPath)

            // Create the new public capability to the roguebunnies_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&roguebunnies_NFT.Collection{roguebunnies_NFT.roguebunnies_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                roguebunnies_NFT.CollectionPublicPath,
                target: roguebunnies_NFT.CollectionStoragePath
            )
        }
    }
}