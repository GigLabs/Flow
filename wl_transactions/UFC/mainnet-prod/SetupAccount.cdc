import NonFungibleToken from 0x1d7e57aa55817448
import UFC_NFT from 0x329feb3ab062d289

// This transaction installs the UFC_NFT collection so an
// account can receive UFC_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&UFC_NFT.Collection>(from: UFC_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-UFC_NFT.createEmptyCollection(), to: UFC_NFT.CollectionStoragePath)

            // Create a public capability to the UFC_NFT collection
            // that exposes the Collection interface
            signer.link<&UFC_NFT.Collection{NonFungibleToken.CollectionPublic,UFC_NFT.UFC_NFTCollectionPublic}>(
                UFC_NFT.CollectionPublicPath,
                target: UFC_NFT.CollectionStoragePath
            )
        }
    }
}