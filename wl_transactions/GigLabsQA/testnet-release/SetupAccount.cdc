import NonFungibleToken from 
import GigLabsQA_NFT from 

// This transaction installs the GigLabsQA_NFT collection so an
// account can receive GigLabsQA_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&GigLabsQA_NFT.Collection>(from: GigLabsQA_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-GigLabsQA_NFT.createEmptyCollection(), to: GigLabsQA_NFT.CollectionStoragePath)

            // Create a public capability to the GigLabsQA_NFT collection
            // that exposes the Collection interface
            signer.link<&GigLabsQA_NFT.Collection{NonFungibleToken.CollectionPublic,GigLabsQA_NFT.GigLabsQA_NFTCollectionPublic}>(
                GigLabsQA_NFT.CollectionPublicPath,
                target: GigLabsQA_NFT.CollectionStoragePath
            )
        }
    }
}