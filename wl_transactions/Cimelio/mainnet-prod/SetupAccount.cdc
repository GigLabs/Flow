import NonFungibleToken from 0x1d7e57aa55817448
import Cimelio_NFT from 0x2c9de937c319468d

// This transaction installs the Cimelio_NFT collection so an
// account can receive Cimelio_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Cimelio_NFT.Collection>(from: Cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Cimelio_NFT.createEmptyCollection(), to: Cimelio_NFT.CollectionStoragePath)

            // Create a public capability to the Cimelio_NFT collection
            // that exposes the Collection interface
            signer.link<&Cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,Cimelio_NFT.Cimelio_NFTCollectionPublic}>(
                Cimelio_NFT.CollectionPublicPath,
                target: Cimelio_NFT.CollectionStoragePath
            )
        }
    }
}