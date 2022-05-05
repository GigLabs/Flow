import NonFungibleToken from 0x631e88ae7f1d7c20
import roguebunnies_NFT from 0x04625c28593d9408

// This transaction installs the roguebunnies_NFT collection so an
// account can receive roguebunnies_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&roguebunnies_NFT.Collection>(from: roguebunnies_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-roguebunnies_NFT.createEmptyCollection(), to: roguebunnies_NFT.CollectionStoragePath)

            // Create a public capability to the roguebunnies_NFT collection
            // that exposes the Collection interface
            signer.link<&roguebunnies_NFT.Collection{NonFungibleToken.CollectionPublic,roguebunnies_NFT.roguebunnies_NFTCollectionPublic}>(
                roguebunnies_NFT.CollectionPublicPath,
                target: roguebunnies_NFT.CollectionStoragePath
            )
        }
    }
}