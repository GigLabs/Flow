import NonFungibleToken from 0x631e88ae7f1d7c20
import fuchibola_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the fuchibola_NFT collection so an
// account can receive fuchibola_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&fuchibola_NFT.Collection>(from: fuchibola_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-fuchibola_NFT.createEmptyCollection(), to: fuchibola_NFT.CollectionStoragePath)

            // Create a public capability to the fuchibola_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&fuchibola_NFT.Collection{NonFungibleToken.CollectionPublic,fuchibola_NFT.fuchibola_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                fuchibola_NFT.CollectionPublicPath,
                target: fuchibola_NFT.CollectionStoragePath
            )
        }
        // If the account already has a fuchibola_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&fuchibola_NFT.Collection{NonFungibleToken.CollectionPublic,fuchibola_NFT.fuchibola_NFTCollectionPublic,MetadataViews.ResolverCollection}>(fuchibola_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the fuchibola_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(fuchibola_NFT.CollectionPublicPath)

            // Create the new public capability to the fuchibola_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&fuchibola_NFT.Collection{NonFungibleToken.CollectionPublic,fuchibola_NFT.fuchibola_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                fuchibola_NFT.CollectionPublicPath,
                target: fuchibola_NFT.CollectionStoragePath
            )
        }
    }
}