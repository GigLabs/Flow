import NonFungibleToken from 0x631e88ae7f1d7c20
import friendsOfFlow_NFT from 0x04625c28593d9408
import MetadataViews from 0x9b053ed2bd3e7339

// This transaction installs the friendsOfFlow_NFT collection so an
// account can receive friendsOfFlow_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&friendsOfFlow_NFT.Collection>(from: friendsOfFlow_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-friendsOfFlow_NFT.createEmptyCollection(), to: friendsOfFlow_NFT.CollectionStoragePath)

            // Create a public capability to the friendsOfFlow_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&friendsOfFlow_NFT.Collection{NonFungibleToken.CollectionPublic,friendsOfFlow_NFT.friendsOfFlow_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                friendsOfFlow_NFT.CollectionPublicPath,
                target: friendsOfFlow_NFT.CollectionStoragePath
            )
        }
        // If the account already has a friendsOfFlow_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&friendsOfFlow_NFT.Collection{NonFungibleToken.CollectionPublic,friendsOfFlow_NFT.friendsOfFlow_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (friendsOfFlow_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the friendsOfFlow_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(friendsOfFlow_NFT.CollectionPublicPath)

            // Create the new public capability to the friendsOfFlow_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&friendsOfFlow_NFT.Collection{NonFungibleToken.CollectionPublic,friendsOfFlow_NFT.friendsOfFlow_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                friendsOfFlow_NFT.CollectionPublicPath,
                target: friendsOfFlow_NFT.CollectionStoragePath
            )
        }
    }
}