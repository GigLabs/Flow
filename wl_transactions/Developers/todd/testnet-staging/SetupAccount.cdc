import NonFungibleToken from 0x631e88ae7f1d7c20
import todddapper_NFT from 0xf3e8f8ae2e9e2fec

// This transaction installs the todddapper_NFT collection so an
// account can receive todddapper_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&todddapper_NFT.Collection>(from: todddapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-todddapper_NFT.createEmptyCollection(), to: todddapper_NFT.CollectionStoragePath)

            // Create a public capability to the todddapper_NFT collection
            // that exposes the Collection interface
            signer.link<&todddapper_NFT.Collection{NonFungibleToken.CollectionPublic,todddapper_NFT.todddapper_NFTCollectionPublic}>(
                todddapper_NFT.CollectionPublicPath,
                target: todddapper_NFT.CollectionStoragePath
            )
        }
    }
}