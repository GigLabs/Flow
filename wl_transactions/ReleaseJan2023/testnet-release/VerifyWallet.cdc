import NonFungibleToken from 0x631e88ae7f1d7c20
import releasejan2023_NFT from 0x5d2efb448f701c35
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the releasejan2023_NFT collection so an
// account can receive releasejan2023_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&releasejan2023_NFT.Collection>(from: releasejan2023_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-releasejan2023_NFT.createEmptyCollection(), to: releasejan2023_NFT.CollectionStoragePath)

            // Create a public capability to the releasejan2023_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&releasejan2023_NFT.Collection{releasejan2023_NFT.releasejan2023_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                releasejan2023_NFT.CollectionPublicPath,
                target: releasejan2023_NFT.CollectionStoragePath
            )
        }
        // If the account already has a releasejan2023_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&releasejan2023_NFT.Collection{releasejan2023_NFT.releasejan2023_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(releasejan2023_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the releasejan2023_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(releasejan2023_NFT.CollectionPublicPath)

            // Create the new public capability to the releasejan2023_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&releasejan2023_NFT.Collection{releasejan2023_NFT.releasejan2023_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                releasejan2023_NFT.CollectionPublicPath,
                target: releasejan2023_NFT.CollectionStoragePath
            )
        }
    }
}