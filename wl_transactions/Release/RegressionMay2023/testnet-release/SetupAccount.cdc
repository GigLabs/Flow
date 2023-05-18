import NonFungibleToken from 0x631e88ae7f1d7c20
import regressionmay2023_NFT from 0xf1f796c8275ba052
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the regressionmay2023_NFT collection so an
// account can receive regressionmay2023_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&regressionmay2023_NFT.Collection>(from: regressionmay2023_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-regressionmay2023_NFT.createEmptyCollection(), to: regressionmay2023_NFT.CollectionStoragePath)

            // Create a public capability to the regressionmay2023_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&regressionmay2023_NFT.Collection{regressionmay2023_NFT.regressionmay2023_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                regressionmay2023_NFT.CollectionPublicPath,
                target: regressionmay2023_NFT.CollectionStoragePath
            )
        }
        // If the account already has a regressionmay2023_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&regressionmay2023_NFT.Collection{regressionmay2023_NFT.regressionmay2023_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(regressionmay2023_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the regressionmay2023_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(regressionmay2023_NFT.CollectionPublicPath)

            // Create the new public capability to the regressionmay2023_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&regressionmay2023_NFT.Collection{regressionmay2023_NFT.regressionmay2023_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                regressionmay2023_NFT.CollectionPublicPath,
                target: regressionmay2023_NFT.CollectionStoragePath
            )
        }
    }
}