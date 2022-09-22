import NonFungibleToken from 0x1d7e57aa55817448
import RogueBunnies_NFT from 0x396646f110afb2e6
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the RogueBunnies_NFT collection so an
// account can receive RogueBunnies_NFT NFTs 

transaction(userId: UInt64) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&RogueBunnies_NFT.Collection>(from: RogueBunnies_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-RogueBunnies_NFT.createEmptyCollection(), to: RogueBunnies_NFT.CollectionStoragePath)

            // Create a public capability to the RogueBunnies_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&RogueBunnies_NFT.Collection{RogueBunnies_NFT.RogueBunnies_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                RogueBunnies_NFT.CollectionPublicPath,
                target: RogueBunnies_NFT.CollectionStoragePath
            )
        }
        // If the account already has a RogueBunnies_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&RogueBunnies_NFT.Collection{RogueBunnies_NFT.RogueBunnies_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(RogueBunnies_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the RogueBunnies_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(RogueBunnies_NFT.CollectionPublicPath)

            // Create the new public capability to the RogueBunnies_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&RogueBunnies_NFT.Collection{RogueBunnies_NFT.RogueBunnies_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                RogueBunnies_NFT.CollectionPublicPath,
                target: RogueBunnies_NFT.CollectionStoragePath
            )
        }
    }
}