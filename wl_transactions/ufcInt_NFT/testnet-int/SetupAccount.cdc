import NonFungibleToken from 0x631e88ae7f1d7c20
import ufcInt_NFT from 0x04625c28593d9408

// This transaction installs the ufcInt_NFT collection so an
// account can receive ufcInt_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&ufcInt_NFT.Collection>(from: ufcInt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-ufcInt_NFT.createEmptyCollection(), to: ufcInt_NFT.CollectionStoragePath)

            // Create a public capability to the ufcInt_NFT collection
            // that exposes the Collection interface
            signer.link<&ufcInt_NFT.Collection{NonFungibleToken.CollectionPublic,ufcInt_NFT.ufcInt_NFTCollectionPublic}>(
                ufcInt_NFT.CollectionPublicPath,
                target: ufcInt_NFT.CollectionStoragePath
            )
        }
    }
}