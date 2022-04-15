import NonFungibleToken from 0x1d7e57aa55817448
import DGD_NFT from 0x329feb3ab062d289

// This transaction installs the DGD_NFT collection so an
// account can receive DGD_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&DGD_NFT.Collection>(from: DGD_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-DGD_NFT.createEmptyCollection(), to: DGD_NFT.CollectionStoragePath)

            // Create a public capability to the DGD_NFT collection
            // that exposes the Collection interface
            signer.link<&DGD_NFT.Collection{NonFungibleToken.CollectionPublic,DGD_NFT.DGD_NFTCollectionPublic}>(
                DGD_NFT.CollectionPublicPath,
                target: DGD_NFT.CollectionStoragePath
            )
        }
    }
}