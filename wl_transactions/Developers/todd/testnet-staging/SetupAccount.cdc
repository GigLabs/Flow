import NonFungibleToken from 0x631e88ae7f1d7c20
import ToddDapper_NFT from 0x074bae238bc6b419

// This transaction installs the ToddDapper_NFT collection so an
// account can receive ToddDapper_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&ToddDapper_NFT.Collection>(from: ToddDapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-ToddDapper_NFT.createEmptyCollection(), to: ToddDapper_NFT.CollectionStoragePath)

            // Create a public capability to the ToddDapper_NFT collection
            // that exposes the Collection interface
            signer.link<&ToddDapper_NFT.Collection{NonFungibleToken.CollectionPublic,ToddDapper_NFT.ToddDapper_NFTCollectionPublic}>(
                ToddDapper_NFT.CollectionPublicPath,
                target: ToddDapper_NFT.CollectionStoragePath
            )
        }
    }
}