import NonFungibleToken from 0x631e88ae7f1d7c20
import ufcInt_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the ufcInt_NFT collection so an
// account can receive ufcInt_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&ufcInt_NFT.Collection>(from: ufcInt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-ufcInt_NFT.createEmptyCollection(), to: ufcInt_NFT.CollectionStoragePath)

            // Create a public capability to the ufcInt_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ufcInt_NFT.Collection{NonFungibleToken.CollectionPublic,ufcInt_NFT.ufcInt_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                ufcInt_NFT.CollectionPublicPath,
                target: ufcInt_NFT.CollectionStoragePath
            )
        }
        // If the account already has a ufcInt_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&ufcInt_NFT.Collection{NonFungibleToken.CollectionPublic,ufcInt_NFT.ufcInt_NFTCollectionPublic,MetadataViews.ResolverCollection}>(ufcInt_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the ufcInt_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(ufcInt_NFT.CollectionPublicPath)

            // Create the new public capability to the ufcInt_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ufcInt_NFT.Collection{NonFungibleToken.CollectionPublic,ufcInt_NFT.ufcInt_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                ufcInt_NFT.CollectionPublicPath,
                target: ufcInt_NFT.CollectionStoragePath
            )
        }
    }
}