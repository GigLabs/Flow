import NonFungibleToken from 0x1d7e57aa55817448
import Cimelio_NFT from 0x2c9de937c319468d
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Cimelio_NFT collection so an
// account can receive Cimelio_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Cimelio_NFT.Collection>(from: Cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Cimelio_NFT.createEmptyCollection(), to: Cimelio_NFT.CollectionStoragePath)

            // Create a public capability to the Cimelio_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Cimelio_NFT.Collection{Cimelio_NFT.Cimelio_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Cimelio_NFT.CollectionPublicPath,
                target: Cimelio_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Cimelio_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Cimelio_NFT.Collection{Cimelio_NFT.Cimelio_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Cimelio_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Cimelio_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Cimelio_NFT.CollectionPublicPath)

            // Create the new public capability to the Cimelio_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Cimelio_NFT.Collection{Cimelio_NFT.Cimelio_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Cimelio_NFT.CollectionPublicPath,
                target: Cimelio_NFT.CollectionStoragePath
            )
        }
    }
}