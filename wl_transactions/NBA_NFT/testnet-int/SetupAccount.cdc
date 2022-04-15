import NonFungibleToken from 0x631e88ae7f1d7c20
import nba_NFT from 0x04625c28593d9408

// This transaction installs the nba_NFT collection so an
// account can receive nba_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&nba_NFT.Collection>(from: nba_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-nba_NFT.createEmptyCollection(), to: nba_NFT.CollectionStoragePath)

            // Create a public capability to the nba_NFT collection
            // that exposes the Collection interface
            signer.link<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic}>(
                nba_NFT.CollectionPublicPath,
                target: nba_NFT.CollectionStoragePath
            )
        }
    }
}