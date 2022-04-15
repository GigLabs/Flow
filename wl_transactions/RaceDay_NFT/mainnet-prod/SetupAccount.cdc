import NonFungibleToken from 0x1d7e57aa55817448
import RaceDay_NFT from 0x329feb3ab062d289

// This transaction installs the RaceDay_NFT collection so an
// account can receive RaceDay_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&RaceDay_NFT.Collection>(from: RaceDay_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-RaceDay_NFT.createEmptyCollection(), to: RaceDay_NFT.CollectionStoragePath)

            // Create a public capability to the RaceDay_NFT collection
            // that exposes the Collection interface
            signer.link<&RaceDay_NFT.Collection{NonFungibleToken.CollectionPublic,RaceDay_NFT.RaceDay_NFTCollectionPublic}>(
                RaceDay_NFT.CollectionPublicPath,
                target: RaceDay_NFT.CollectionStoragePath
            )
        }
    }
}