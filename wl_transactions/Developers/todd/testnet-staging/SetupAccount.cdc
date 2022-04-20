import NonFungibleToken from 0x631e88ae7f1d7c20
import toddlocal_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the toddlocal_NFT collection so an
// account can receive toddlocal_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&toddlocal_NFT.Collection>(from: toddlocal_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-toddlocal_NFT.createEmptyCollection(), to: toddlocal_NFT.CollectionStoragePath)

            // Create a public capability to the toddlocal_NFT collection
            // that exposes the Collection interface
            signer.link<&toddlocal_NFT.Collection{NonFungibleToken.CollectionPublic,toddlocal_NFT.toddlocal_NFTCollectionPublic}>(
                toddlocal_NFT.CollectionPublicPath,
                target: toddlocal_NFT.CollectionStoragePath
            )
        }
    }
}