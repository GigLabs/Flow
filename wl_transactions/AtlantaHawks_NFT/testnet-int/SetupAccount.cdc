import NonFungibleToken from 0x631e88ae7f1d7c20
import atlantahawks_NFT from 0x04625c28593d9408

// This transaction installs the atlantahawks_NFT collection so an
// account can receive atlantahawks_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&atlantahawks_NFT.Collection>(from: atlantahawks_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-atlantahawks_NFT.createEmptyCollection(), to: atlantahawks_NFT.CollectionStoragePath)

            // Create a public capability to the atlantahawks_NFT collection
            // that exposes the Collection interface
            signer.link<&atlantahawks_NFT.Collection{NonFungibleToken.CollectionPublic,atlantahawks_NFT.atlantahawks_NFTCollectionPublic}>(
                atlantahawks_NFT.CollectionPublicPath,
                target: atlantahawks_NFT.CollectionStoragePath
            )
        }
    }
}