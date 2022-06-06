import NonFungibleToken from 0x631e88ae7f1d7c20
import izon_NFT from 0x04625c28593d9408

// This transaction installs the izon_NFT collection so an
// account can receive izon_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&izon_NFT.Collection>(from: izon_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-izon_NFT.createEmptyCollection(), to: izon_NFT.CollectionStoragePath)

            // Create a public capability to the izon_NFT collection
            // that exposes the Collection interface
            signer.link<&izon_NFT.Collection{NonFungibleToken.CollectionPublic,izon_NFT.izon_NFTCollectionPublic}>(
                izon_NFT.CollectionPublicPath,
                target: izon_NFT.CollectionStoragePath
            )
        }
    }
}