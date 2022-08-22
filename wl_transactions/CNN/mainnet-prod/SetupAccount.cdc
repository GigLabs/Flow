import NonFungibleToken from 0x1d7e57aa55817448
import CNN_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the CNN_NFT collection so an
// account can receive CNN_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&CNN_NFT.Collection>(from: CNN_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-CNN_NFT.createEmptyCollection(), to: CNN_NFT.CollectionStoragePath)

            // Create a public capability to the CNN_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&CNN_NFT.Collection{CNN_NFT.CNN_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                CNN_NFT.CollectionPublicPath,
                target: CNN_NFT.CollectionStoragePath
            )
        }
        // If the account already has a CNN_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&CNN_NFT.Collection{CNN_NFT.CNN_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(CNN_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the CNN_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(CNN_NFT.CollectionPublicPath)

            // Create the new public capability to the CNN_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&CNN_NFT.Collection{CNN_NFT.CNN_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                CNN_NFT.CollectionPublicPath,
                target: CNN_NFT.CollectionStoragePath
            )
        }
    }
}