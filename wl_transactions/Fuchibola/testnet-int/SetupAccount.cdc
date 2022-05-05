import NonFungibleToken from 0x631e88ae7f1d7c20
import fuchibola_NFT from 0x04625c28593d9408

// This transaction installs the fuchibola_NFT collection so an
// account can receive fuchibola_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&fuchibola_NFT.Collection>(from: fuchibola_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-fuchibola_NFT.createEmptyCollection(), to: fuchibola_NFT.CollectionStoragePath)

            // Create a public capability to the fuchibola_NFT collection
            // that exposes the Collection interface
            signer.link<&fuchibola_NFT.Collection{NonFungibleToken.CollectionPublic,fuchibola_NFT.fuchibola_NFTCollectionPublic}>(
                fuchibola_NFT.CollectionPublicPath,
                target: fuchibola_NFT.CollectionStoragePath
            )
        }
    }
}