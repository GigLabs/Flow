import NonFungibleToken from 0x631e88ae7f1d7c20
import ToddDapper_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x9b053ed2bd3e7339

// This transaction installs the ToddDapper_NFT collection so an
// account can receive ToddDapper_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&ToddDapper_NFT.Collection>(from: ToddDapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-ToddDapper_NFT.createEmptyCollection(), to: ToddDapper_NFT.CollectionStoragePath)

            // Create a public capability to the ToddDapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ToddDapper_NFT.Collection{NonFungibleToken.CollectionPublic,ToddDapper_NFT.ToddDapper_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                ToddDapper_NFT.CollectionPublicPath,
                target: ToddDapper_NFT.CollectionStoragePath
            )
        }
        // If the account already has a ToddDapper_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&ToddDapper_NFT.Collection{NonFungibleToken.CollectionPublic,ToddDapper_NFT.ToddDapper_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (ToddDapper_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the ToddDapper_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(ToddDapper_NFT.CollectionPublicPath)

            // Create the new public capability to the ToddDapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ToddDapper_NFT.Collection{NonFungibleToken.CollectionPublic,ToddDapper_NFT.ToddDapper_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                ToddDapper_NFT.CollectionPublicPath,
                target: ToddDapper_NFT.CollectionStoragePath
            )
        }
    }
}