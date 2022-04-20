import NonFungibleToken from 0x1d7e57aa55817448
import CNN_NFT from 0x329feb3ab062d289

// This transaction installs the CNN_NFT collection so an
// account can receive CNN_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&CNN_NFT.Collection>(from: CNN_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-CNN_NFT.createEmptyCollection(), to: CNN_NFT.CollectionStoragePath)

            // Create a public capability to the CNN_NFT collection
            // that exposes the Collection interface
            signer.link<&CNN_NFT.Collection{NonFungibleToken.CollectionPublic,CNN_NFT.CNN_NFTCollectionPublic}>(
                CNN_NFT.CollectionPublicPath,
                target: CNN_NFT.CollectionStoragePath
            )
        }
    }
}