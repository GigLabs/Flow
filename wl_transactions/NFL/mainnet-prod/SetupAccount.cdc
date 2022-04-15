import NonFungibleToken from 0x1d7e57aa55817448
import NFL_NFT from 0x329feb3ab062d289

// This transaction installs the NFL_NFT collection so an
// account can receive NFL_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&NFL_NFT.Collection>(from: NFL_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-NFL_NFT.createEmptyCollection(), to: NFL_NFT.CollectionStoragePath)

            // Create a public capability to the NFL_NFT collection
            // that exposes the Collection interface
            signer.link<&NFL_NFT.Collection{NonFungibleToken.CollectionPublic,NFL_NFT.NFL_NFTCollectionPublic}>(
                NFL_NFT.CollectionPublicPath,
                target: NFL_NFT.CollectionStoragePath
            )
        }
    }
}