import NonFungibleToken from 0x631e88ae7f1d7c20
import nflInt_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the nflInt_NFT collection so an
// account can receive nflInt_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&nflInt_NFT.Collection>(from: nflInt_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-nflInt_NFT.createEmptyCollection(), to: nflInt_NFT.CollectionStoragePath)

            // Create a public capability to the nflInt_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&nflInt_NFT.Collection{NonFungibleToken.CollectionPublic,nflInt_NFT.nflInt_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                nflInt_NFT.CollectionPublicPath,
                target: nflInt_NFT.CollectionStoragePath
            )
        }
        // If the account already has a nflInt_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&nflInt_NFT.Collection{NonFungibleToken.CollectionPublic,nflInt_NFT.nflInt_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (nflInt_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the nflInt_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(nflInt_NFT.CollectionPublicPath)

            // Create the new public capability to the nflInt_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&nflInt_NFT.Collection{NonFungibleToken.CollectionPublic,nflInt_NFT.nflInt_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                nflInt_NFT.CollectionPublicPath,
                target: nflInt_NFT.CollectionStoragePath
            )
        }
    }
}