import NonFungibleToken from 0x631e88ae7f1d7c20
import breakingt_NFT from 0x04625c28593d9408

// This transaction installs the breakingt_NFT collection so an
// account can receive breakingt_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&breakingt_NFT.Collection>(from: breakingt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-breakingt_NFT.createEmptyCollection(), to: breakingt_NFT.CollectionStoragePath)

            // Create a public capability to the breakingt_NFT collection
            // that exposes the Collection interface
            signer.link<&breakingt_NFT.Collection{NonFungibleToken.CollectionPublic,breakingt_NFT.breakingt_NFTCollectionPublic}>(
                breakingt_NFT.CollectionPublicPath,
                target: breakingt_NFT.CollectionStoragePath
            )
        }
    }
}