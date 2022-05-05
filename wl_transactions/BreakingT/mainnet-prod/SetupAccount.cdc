import NonFungibleToken from 0x1d7e57aa55817448
import BreakingT_NFT from 0x329feb3ab062d289

// This transaction installs the BreakingT_NFT collection so an
// account can receive BreakingT_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-BreakingT_NFT.createEmptyCollection(), to: BreakingT_NFT.CollectionStoragePath)

            // Create a public capability to the BreakingT_NFT collection
            // that exposes the Collection interface
            signer.link<&BreakingT_NFT.Collection{NonFungibleToken.CollectionPublic,BreakingT_NFT.BreakingT_NFTCollectionPublic}>(
                BreakingT_NFT.CollectionPublicPath,
                target: BreakingT_NFT.CollectionStoragePath
            )
        }
    }
}