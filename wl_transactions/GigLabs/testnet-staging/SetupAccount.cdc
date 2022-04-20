import NonFungibleToken from 0x631e88ae7f1d7c20
import giglabs_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the giglabs_NFT collection so an
// account can receive giglabs_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&giglabs_NFT.Collection>(from: giglabs_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-giglabs_NFT.createEmptyCollection(), to: giglabs_NFT.CollectionStoragePath)

            // Create a public capability to the giglabs_NFT collection
            // that exposes the Collection interface
            signer.link<&giglabs_NFT.Collection{NonFungibleToken.CollectionPublic,giglabs_NFT.giglabs_NFTCollectionPublic}>(
                giglabs_NFT.CollectionPublicPath,
                target: giglabs_NFT.CollectionStoragePath
            )
        }
    }
}