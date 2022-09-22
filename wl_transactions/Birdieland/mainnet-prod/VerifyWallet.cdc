import NonFungibleToken from 0x1d7e57aa55817448
import Birdieland_NFT from 0x59e3d094592231a7
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Birdieland_NFT collection so an
// account can receive Birdieland_NFT NFTs 

transaction(userId: UInt64) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Birdieland_NFT.Collection>(from: Birdieland_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Birdieland_NFT.createEmptyCollection(), to: Birdieland_NFT.CollectionStoragePath)

            // Create a public capability to the Birdieland_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Birdieland_NFT.Collection{Birdieland_NFT.Birdieland_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Birdieland_NFT.CollectionPublicPath,
                target: Birdieland_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Birdieland_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Birdieland_NFT.Collection{Birdieland_NFT.Birdieland_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Birdieland_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Birdieland_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Birdieland_NFT.CollectionPublicPath)

            // Create the new public capability to the Birdieland_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Birdieland_NFT.Collection{Birdieland_NFT.Birdieland_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Birdieland_NFT.CollectionPublicPath,
                target: Birdieland_NFT.CollectionStoragePath
            )
        }
    }
}