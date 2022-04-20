import NonFungibleToken from 0x631e88ae7f1d7c20
import CNN_INT_NFT from 0x04625c28593d9408

// This transaction installs the CNN_INT_NFT collection so an
// account can receive CNN_INT_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&CNN_INT_NFT.Collection>(from: CNN_INT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-CNN_INT_NFT.createEmptyCollection(), to: CNN_INT_NFT.CollectionStoragePath)

            // Create a public capability to the CNN_INT_NFT collection
            // that exposes the Collection interface
            signer.link<&CNN_INT_NFT.Collection{NonFungibleToken.CollectionPublic,CNN_INT_NFT.CNN_INT_NFTCollectionPublic}>(
                CNN_INT_NFT.CollectionPublicPath,
                target: CNN_INT_NFT.CollectionStoragePath
            )
        }
    }
}