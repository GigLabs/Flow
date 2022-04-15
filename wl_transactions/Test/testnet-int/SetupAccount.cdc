import NonFungibleToken from 0x631e88ae7f1d7c20
import test_NFT from 0x04625c28593d9408

// This transaction installs the test_NFT collection so an
// account can receive test_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&test_NFT.Collection>(from: test_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-test_NFT.createEmptyCollection(), to: test_NFT.CollectionStoragePath)

            // Create a public capability to the test_NFT collection
            // that exposes the Collection interface
            signer.link<&test_NFT.Collection{NonFungibleToken.CollectionPublic,test_NFT.test_NFTCollectionPublic}>(
                test_NFT.CollectionPublicPath,
                target: test_NFT.CollectionStoragePath
            )
        }
    }
}