import NonFungibleToken from 0x631e88ae7f1d7c20
import ToddDapper_NFT from 0x074bae238bc6b419
import MetadataViews from 0x631e88ae7f1d7c20

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
            signer.link<&ToddDapper_NFT.Collection{ToddDapper_NFT.ToddDapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                ToddDapper_NFT.CollectionPublicPath,
                target: ToddDapper_NFT.CollectionStoragePath
            )
        }
        // If the account already has a ToddDapper_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&ToddDapper_NFT.Collection{ToddDapper_NFT.ToddDapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(ToddDapper_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the ToddDapper_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(ToddDapper_NFT.CollectionPublicPath)

            // Create the new public capability to the ToddDapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ToddDapper_NFT.Collection{ToddDapper_NFT.ToddDapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                ToddDapper_NFT.CollectionPublicPath,
                target: ToddDapper_NFT.CollectionStoragePath
            )
        }
    }
}