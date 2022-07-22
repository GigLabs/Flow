import NonFungibleToken from 0x1d7e57aa55817448
import FriendsOfFlow_NFT from 0xcee3d6cc34301ad1

// This transaction installs the FriendsOfFlow_NFT collection so an
// account can receive FriendsOfFlow_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&FriendsOfFlow_NFT.Collection>(from: FriendsOfFlow_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-FriendsOfFlow_NFT.createEmptyCollection(), to: FriendsOfFlow_NFT.CollectionStoragePath)

            // Create a public capability to the FriendsOfFlow_NFT collection
            // that exposes the Collection interface
            signer.link<&FriendsOfFlow_NFT.Collection{NonFungibleToken.CollectionPublic,FriendsOfFlow_NFT.FriendsOfFlow_NFTCollectionPublic}>(
                FriendsOfFlow_NFT.CollectionPublicPath,
                target: FriendsOfFlow_NFT.CollectionStoragePath
            )
        }
    }
}