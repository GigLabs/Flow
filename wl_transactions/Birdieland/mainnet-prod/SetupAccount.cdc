import NonFungibleToken from 0x1d7e57aa55817448
import Birdieland_NFT from 0x59e3d094592231a7

// This transaction installs the Birdieland_NFT collection so an
// account can receive Birdieland_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Birdieland_NFT.Collection>(from: Birdieland_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Birdieland_NFT.createEmptyCollection(), to: Birdieland_NFT.CollectionStoragePath)

            // Create a public capability to the Birdieland_NFT collection
            // that exposes the Collection interface
            signer.link<&Birdieland_NFT.Collection{NonFungibleToken.CollectionPublic,Birdieland_NFT.Birdieland_NFTCollectionPublic}>(
                Birdieland_NFT.CollectionPublicPath,
                target: Birdieland_NFT.CollectionStoragePath
            )
        }
    }
}