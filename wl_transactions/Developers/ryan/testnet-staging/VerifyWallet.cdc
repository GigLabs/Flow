import NonFungibleToken from 0x631e88ae7f1d7c20
import ryandapper_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the ryandapper_NFT collection so an
// account can receive ryandapper_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&ryandapper_NFT.Collection>(from: ryandapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-ryandapper_NFT.createEmptyCollection(), to: ryandapper_NFT.CollectionStoragePath)

            // Create a public capability to the ryandapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ryandapper_NFT.Collection{ryandapper_NFT.ryandapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                ryandapper_NFT.CollectionPublicPath,
                target: ryandapper_NFT.CollectionStoragePath
            )
        }
        // If the account already has a ryandapper_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&ryandapper_NFT.Collection{ryandapper_NFT.ryandapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(ryandapper_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the ryandapper_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(ryandapper_NFT.CollectionPublicPath)

            // Create the new public capability to the ryandapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&ryandapper_NFT.Collection{ryandapper_NFT.ryandapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                ryandapper_NFT.CollectionPublicPath,
                target: ryandapper_NFT.CollectionStoragePath
            )
        }
    }
}