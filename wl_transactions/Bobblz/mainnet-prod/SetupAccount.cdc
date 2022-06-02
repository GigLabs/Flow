import NonFungibleToken from 0x1d7e57aa55817448
import Bobblz_NFT from 0xd45e2bd9a3d5003b

// This transaction installs the Bobblz_NFT collection so an
// account can receive Bobblz_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Bobblz_NFT.Collection>(from: Bobblz_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Bobblz_NFT.createEmptyCollection(), to: Bobblz_NFT.CollectionStoragePath)

            // Create a public capability to the Bobblz_NFT collection
            // that exposes the Collection interface
            signer.link<&Bobblz_NFT.Collection{NonFungibleToken.CollectionPublic,Bobblz_NFT.Bobblz_NFTCollectionPublic}>(
                Bobblz_NFT.CollectionPublicPath,
                target: Bobblz_NFT.CollectionStoragePath
            )
        }
    }
}