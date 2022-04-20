import NonFungibleToken from 0x631e88ae7f1d7c20
import cnn_NFT from 0x04625c28593d9408

// This transaction installs the cnn_NFT collection so an
// account can receive cnn_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&cnn_NFT.Collection>(from: cnn_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-cnn_NFT.createEmptyCollection(), to: cnn_NFT.CollectionStoragePath)

            // Create a public capability to the cnn_NFT collection
            // that exposes the Collection interface
            signer.link<&cnn_NFT.Collection{NonFungibleToken.CollectionPublic,cnn_NFT.cnn_NFTCollectionPublic}>(
                cnn_NFT.CollectionPublicPath,
                target: cnn_NFT.CollectionStoragePath
            )
        }
    }
}