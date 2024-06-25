import NonFungibleToken from 0x1d7e57aa55817448
import BWAYX_NFT from 0xf02b15e11eb3715b
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the BWAYX_NFT collection so an
// account can receive BWAYX_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&BWAYX_NFT.Collection>(from: BWAYX_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-BWAYX_NFT.createEmptyCollection(), to: BWAYX_NFT.CollectionStoragePath)

            // Create a public capability to the BWAYX_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&BWAYX_NFT.Collection{BWAYX_NFT.BWAYX_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                BWAYX_NFT.CollectionPublicPath,
                target: BWAYX_NFT.CollectionStoragePath
            )
        }
        // If the account already has a BWAYX_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&BWAYX_NFT.Collection{BWAYX_NFT.BWAYX_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(BWAYX_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the BWAYX_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(BWAYX_NFT.CollectionPublicPath)

            // Create the new public capability to the BWAYX_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&BWAYX_NFT.Collection{BWAYX_NFT.BWAYX_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                BWAYX_NFT.CollectionPublicPath,
                target: BWAYX_NFT.CollectionStoragePath
            )
        }
    }
}