import NonFungibleToken from 0x631e88ae7f1d7c20
import cimelio_NFT from 0x04625c28593d9408

// This transaction installs the cimelio_NFT collection so an
// account can receive cimelio_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&cimelio_NFT.Collection>(from: cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-cimelio_NFT.createEmptyCollection(), to: cimelio_NFT.CollectionStoragePath)

            // Create a public capability to the cimelio_NFT collection
            // that exposes the Collection interface
            signer.link<&cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,cimelio_NFT.cimelio_NFTCollectionPublic}>(
                cimelio_NFT.CollectionPublicPath,
                target: cimelio_NFT.CollectionStoragePath
            )
        }
    }
}