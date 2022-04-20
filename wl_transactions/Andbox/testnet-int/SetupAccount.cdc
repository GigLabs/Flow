import NonFungibleToken from 0x631e88ae7f1d7c20
import AndBoxINT_NFT from 0x04625c28593d9408

// This transaction installs the AndBoxINT_NFT collection so an
// account can receive AndBoxINT_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&AndBoxINT_NFT.Collection>(from: AndBoxINT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-AndBoxINT_NFT.createEmptyCollection(), to: AndBoxINT_NFT.CollectionStoragePath)

            // Create a public capability to the AndBoxINT_NFT collection
            // that exposes the Collection interface
            signer.link<&AndBoxINT_NFT.Collection{NonFungibleToken.CollectionPublic,AndBoxINT_NFT.AndBoxINT_NFTCollectionPublic}>(
                AndBoxINT_NFT.CollectionPublicPath,
                target: AndBoxINT_NFT.CollectionStoragePath
            )
        }
    }
}