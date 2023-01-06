import NonFungibleToken from 0x631e88ae7f1d7c20
import bwayx_NFT from 0x477638bc70a9341e
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the bwayx_NFT collection so an
// account can receive bwayx_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&bwayx_NFT.Collection>(from: bwayx_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-bwayx_NFT.createEmptyCollection(), to: bwayx_NFT.CollectionStoragePath)

            // Create a public capability to the bwayx_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&bwayx_NFT.Collection{bwayx_NFT.bwayx_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                bwayx_NFT.CollectionPublicPath,
                target: bwayx_NFT.CollectionStoragePath
            )
        }
        // If the account already has a bwayx_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&bwayx_NFT.Collection{bwayx_NFT.bwayx_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(bwayx_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the bwayx_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(bwayx_NFT.CollectionPublicPath)

            // Create the new public capability to the bwayx_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&bwayx_NFT.Collection{bwayx_NFT.bwayx_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                bwayx_NFT.CollectionPublicPath,
                target: bwayx_NFT.CollectionStoragePath
            )
        }
    }
}