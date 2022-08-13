import NonFungibleToken from 0x631e88ae7f1d7c20
import toddlocal_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x9b053ed2bd3e7339

// This transaction installs the toddlocal_NFT collection so an
// account can receive toddlocal_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&toddlocal_NFT.Collection>(from: toddlocal_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-toddlocal_NFT.createEmptyCollection(), to: toddlocal_NFT.CollectionStoragePath)

            // Create a public capability to the toddlocal_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&toddlocal_NFT.Collection{NonFungibleToken.CollectionPublic,toddlocal_NFT.toddlocal_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                toddlocal_NFT.CollectionPublicPath,
                target: toddlocal_NFT.CollectionStoragePath
            )
        }
        // If the account already has a toddlocal_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&toddlocal_NFT.Collection{NonFungibleToken.CollectionPublic,toddlocal_NFT.toddlocal_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (toddlocal_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the toddlocal_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(toddlocal_NFT.CollectionPublicPath)

            // Create the new public capability to the toddlocal_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&toddlocal_NFT.Collection{NonFungibleToken.CollectionPublic,toddlocal_NFT.toddlocal_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                toddlocal_NFT.CollectionPublicPath,
                target: toddlocal_NFT.CollectionStoragePath
            )
        }
    }
}