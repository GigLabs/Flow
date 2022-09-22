import NonFungibleToken from 0x1d7e57aa55817448
import Costacos_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Costacos_NFT collection so an
// account can receive Costacos_NFT NFTs 

transaction(userId: UInt64) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Costacos_NFT.Collection>(from: Costacos_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Costacos_NFT.createEmptyCollection(), to: Costacos_NFT.CollectionStoragePath)

            // Create a public capability to the Costacos_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Costacos_NFT.Collection{Costacos_NFT.Costacos_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Costacos_NFT.CollectionPublicPath,
                target: Costacos_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Costacos_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Costacos_NFT.Collection{Costacos_NFT.Costacos_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Costacos_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Costacos_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Costacos_NFT.CollectionPublicPath)

            // Create the new public capability to the Costacos_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Costacos_NFT.Collection{Costacos_NFT.Costacos_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Costacos_NFT.CollectionPublicPath,
                target: Costacos_NFT.CollectionStoragePath
            )
        }
    }
}