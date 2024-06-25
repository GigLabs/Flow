import NonFungibleToken from 0x631e88ae7f1d7c20
import CNN_INT_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the CNN_INT_NFT collection so an
// account can receive CNN_INT_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&CNN_INT_NFT.Collection>(from: CNN_INT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-CNN_INT_NFT.createEmptyCollection(), to: CNN_INT_NFT.CollectionStoragePath)

            // Create a public capability to the CNN_INT_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&CNN_INT_NFT.Collection{CNN_INT_NFT.CNN_INT_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                CNN_INT_NFT.CollectionPublicPath,
                target: CNN_INT_NFT.CollectionStoragePath
            )
        }
        // If the account already has a CNN_INT_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&CNN_INT_NFT.Collection{CNN_INT_NFT.CNN_INT_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(CNN_INT_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the CNN_INT_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(CNN_INT_NFT.CollectionPublicPath)

            // Create the new public capability to the CNN_INT_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&CNN_INT_NFT.Collection{CNN_INT_NFT.CNN_INT_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                CNN_INT_NFT.CollectionPublicPath,
                target: CNN_INT_NFT.CollectionStoragePath
            )
        }
    }
}