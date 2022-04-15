import NonFungibleToken from 0x631e88ae7f1d7c20
import dgd_NFT from 0x04625c28593d9408

// This transaction installs the dgd_NFT collection so an
// account can receive dgd_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&dgd_NFT.Collection>(from: dgd_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-dgd_NFT.createEmptyCollection(), to: dgd_NFT.CollectionStoragePath)

            // Create a public capability to the dgd_NFT collection
            // that exposes the Collection interface
            signer.link<&dgd_NFT.Collection{NonFungibleToken.CollectionPublic,dgd_NFT.dgd_NFTCollectionPublic}>(
                dgd_NFT.CollectionPublicPath,
                target: dgd_NFT.CollectionStoragePath
            )
        }
    }
}