import NonFungibleToken from 0x1d7e57aa55817448
import Fuchibola_NFT from 0xf3ee684cd0259fed
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Fuchibola_NFT collection so an
// account can receive Fuchibola_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Fuchibola_NFT.Collection>(from: Fuchibola_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Fuchibola_NFT.createEmptyCollection(), to: Fuchibola_NFT.CollectionStoragePath)

            // Create a public capability to the Fuchibola_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Fuchibola_NFT.Collection{Fuchibola_NFT.Fuchibola_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Fuchibola_NFT.CollectionPublicPath,
                target: Fuchibola_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Fuchibola_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Fuchibola_NFT.Collection{Fuchibola_NFT.Fuchibola_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Fuchibola_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Fuchibola_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Fuchibola_NFT.CollectionPublicPath)

            // Create the new public capability to the Fuchibola_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Fuchibola_NFT.Collection{Fuchibola_NFT.Fuchibola_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Fuchibola_NFT.CollectionPublicPath,
                target: Fuchibola_NFT.CollectionStoragePath
            )
        }
    }
}