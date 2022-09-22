import NonFungibleToken from 0x1d7e57aa55817448
import FriendsOfFlow_NFT from 0xcee3d6cc34301ad1
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the FriendsOfFlow_NFT collection so an
// account can receive FriendsOfFlow_NFT NFTs 

transaction(userId: UInt64) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&FriendsOfFlow_NFT.Collection>(from: FriendsOfFlow_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-FriendsOfFlow_NFT.createEmptyCollection(), to: FriendsOfFlow_NFT.CollectionStoragePath)

            // Create a public capability to the FriendsOfFlow_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&FriendsOfFlow_NFT.Collection{FriendsOfFlow_NFT.FriendsOfFlow_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                FriendsOfFlow_NFT.CollectionPublicPath,
                target: FriendsOfFlow_NFT.CollectionStoragePath
            )
        }
        // If the account already has a FriendsOfFlow_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&FriendsOfFlow_NFT.Collection{FriendsOfFlow_NFT.FriendsOfFlow_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(FriendsOfFlow_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the FriendsOfFlow_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(FriendsOfFlow_NFT.CollectionPublicPath)

            // Create the new public capability to the FriendsOfFlow_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&FriendsOfFlow_NFT.Collection{FriendsOfFlow_NFT.FriendsOfFlow_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                FriendsOfFlow_NFT.CollectionPublicPath,
                target: FriendsOfFlow_NFT.CollectionStoragePath
            )
        }
    }
}