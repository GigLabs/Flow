import NonFungibleToken from 0x1d7e57aa55817448
import NBA_NFT from 0x54317f5ad2f47ad3

// This transaction installs the NBA_NFT collection so an
// account can receive NBA_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&NBA_NFT.Collection>(from: NBA_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-NBA_NFT.createEmptyCollection(), to: NBA_NFT.CollectionStoragePath)

            // Create a public capability to the NBA_NFT collection
            // that exposes the Collection interface
            signer.link<&NBA_NFT.Collection{NonFungibleToken.CollectionPublic,NBA_NFT.NBA_NFTCollectionPublic}>(
                NBA_NFT.CollectionPublicPath,
                target: NBA_NFT.CollectionStoragePath
            )
        }
    }
}