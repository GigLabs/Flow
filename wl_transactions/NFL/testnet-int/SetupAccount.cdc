import NonFungibleToken from 0x631e88ae7f1d7c20
import nflInt_NFT from 0x04625c28593d9408

// This transaction installs the nflInt_NFT collection so an
// account can receive nflInt_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&nflInt_NFT.Collection>(from: nflInt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-nflInt_NFT.createEmptyCollection(), to: nflInt_NFT.CollectionStoragePath)

            // Create a public capability to the nflInt_NFT collection
            // that exposes the Collection interface
            signer.link<&nflInt_NFT.Collection{NonFungibleToken.CollectionPublic,nflInt_NFT.nflInt_NFTCollectionPublic}>(
                nflInt_NFT.CollectionPublicPath,
                target: nflInt_NFT.CollectionStoragePath
            )
        }
    }
}