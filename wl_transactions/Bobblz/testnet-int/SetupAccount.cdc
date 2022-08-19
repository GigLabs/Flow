import NonFungibleToken from 0x631e88ae7f1d7c20
import bobblz_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the bobblz_NFT collection so an
// account can receive bobblz_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&bobblz_NFT.Collection>(from: bobblz_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-bobblz_NFT.createEmptyCollection(), to: bobblz_NFT.CollectionStoragePath)

            // Create a public capability to the bobblz_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&bobblz_NFT.Collection{NonFungibleToken.CollectionPublic,bobblz_NFT.bobblz_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                bobblz_NFT.CollectionPublicPath,
                target: bobblz_NFT.CollectionStoragePath
            )
        }
        // If the account already has a bobblz_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&bobblz_NFT.Collection{NonFungibleToken.CollectionPublic,bobblz_NFT.bobblz_NFTCollectionPublic,MetadataViews.ResolverCollection}>(bobblz_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the bobblz_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(bobblz_NFT.CollectionPublicPath)

            // Create the new public capability to the bobblz_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&bobblz_NFT.Collection{NonFungibleToken.CollectionPublic,bobblz_NFT.bobblz_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                bobblz_NFT.CollectionPublicPath,
                target: bobblz_NFT.CollectionStoragePath
            )
        }
    }
}