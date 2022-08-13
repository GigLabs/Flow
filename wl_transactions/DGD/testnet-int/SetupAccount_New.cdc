import NonFungibleToken from 0x631e88ae7f1d7c20
import dgd_NFT from 0x04625c28593d9408
import MetadataViews from 0x9b053ed2bd3e7339

// This transaction installs the dgd_NFT collection so an
// account can receive dgd_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&dgd_NFT.Collection>(from: dgd_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-dgd_NFT.createEmptyCollection(), to: dgd_NFT.CollectionStoragePath)

            // Create a public capability to the dgd_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&dgd_NFT.Collection{NonFungibleToken.CollectionPublic,dgd_NFT.dgd_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                dgd_NFT.CollectionPublicPath,
                target: dgd_NFT.CollectionStoragePath
            )
        }
        // If the account already has a dgd_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&dgd_NFT.Collection{NonFungibleToken.CollectionPublic,dgd_NFT.dgd_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (dgd_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the dgd_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(dgd_NFT.CollectionPublicPath)

            // Create the new public capability to the dgd_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&dgd_NFT.Collection{NonFungibleToken.CollectionPublic,dgd_NFT.dgd_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                dgd_NFT.CollectionPublicPath,
                target: dgd_NFT.CollectionStoragePath
            )
        }
    }
}