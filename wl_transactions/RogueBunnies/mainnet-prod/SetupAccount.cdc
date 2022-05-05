import NonFungibleToken from 0x1d7e57aa55817448
import RogueBunnies_NFT from 0x396646f110afb2e6

// This transaction installs the RogueBunnies_NFT collection so an
// account can receive RogueBunnies_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&RogueBunnies_NFT.Collection>(from: RogueBunnies_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-RogueBunnies_NFT.createEmptyCollection(), to: RogueBunnies_NFT.CollectionStoragePath)

            // Create a public capability to the RogueBunnies_NFT collection
            // that exposes the Collection interface
            signer.link<&RogueBunnies_NFT.Collection{NonFungibleToken.CollectionPublic,RogueBunnies_NFT.RogueBunnies_NFTCollectionPublic}>(
                RogueBunnies_NFT.CollectionPublicPath,
                target: RogueBunnies_NFT.CollectionStoragePath
            )
        }
    }
}