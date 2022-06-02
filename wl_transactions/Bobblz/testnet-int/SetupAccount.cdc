import NonFungibleToken from 0x631e88ae7f1d7c20
import bobblz_NFT from 0x04625c28593d9408

// This transaction installs the bobblz_NFT collection so an
// account can receive bobblz_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&bobblz_NFT.Collection>(from: bobblz_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-bobblz_NFT.createEmptyCollection(), to: bobblz_NFT.CollectionStoragePath)

            // Create a public capability to the bobblz_NFT collection
            // that exposes the Collection interface
            signer.link<&bobblz_NFT.Collection{NonFungibleToken.CollectionPublic,bobblz_NFT.bobblz_NFTCollectionPublic}>(
                bobblz_NFT.CollectionPublicPath,
                target: bobblz_NFT.CollectionStoragePath
            )
        }
    }
}