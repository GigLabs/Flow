import NonFungibleToken from 0x631e88ae7f1d7c20
import cimelio_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the cimelio_NFT collection so an
// account can receive cimelio_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&cimelio_NFT.Collection>(from: cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-cimelio_NFT.createEmptyCollection(), to: cimelio_NFT.CollectionStoragePath)

            // Create a public capability to the cimelio_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&cimelio_NFT.Collection{cimelio_NFT.cimelio_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                cimelio_NFT.CollectionPublicPath,
                target: cimelio_NFT.CollectionStoragePath
            )
        }
        // If the account already has a cimelio_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&cimelio_NFT.Collection{cimelio_NFT.cimelio_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(cimelio_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the cimelio_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(cimelio_NFT.CollectionPublicPath)

            // Create the new public capability to the cimelio_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&cimelio_NFT.Collection{cimelio_NFT.cimelio_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                cimelio_NFT.CollectionPublicPath,
                target: cimelio_NFT.CollectionStoragePath
            )
        }
    }
}