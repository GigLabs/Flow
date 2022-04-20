import NonFungibleToken from 0x631e88ae7f1d7c20
import andbox_NFT from 0x04625c28593d9408

// This transaction installs the andbox_NFT collection so an
// account can receive andbox_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&andbox_NFT.Collection>(from: andbox_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-andbox_NFT.createEmptyCollection(), to: andbox_NFT.CollectionStoragePath)

            // Create a public capability to the andbox_NFT collection
            // that exposes the Collection interface
            signer.link<&andbox_NFT.Collection{NonFungibleToken.CollectionPublic,andbox_NFT.andbox_NFTCollectionPublic}>(
                andbox_NFT.CollectionPublicPath,
                target: andbox_NFT.CollectionStoragePath
            )
        }
    }
}