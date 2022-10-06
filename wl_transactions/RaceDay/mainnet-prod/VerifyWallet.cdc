import NonFungibleToken from 0x1d7e57aa55817448
import RaceDay_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the RaceDay_NFT collection so an
// account can receive RaceDay_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&RaceDay_NFT.Collection>(from: RaceDay_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-RaceDay_NFT.createEmptyCollection(), to: RaceDay_NFT.CollectionStoragePath)

            // Create a public capability to the RaceDay_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&RaceDay_NFT.Collection{RaceDay_NFT.RaceDay_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                RaceDay_NFT.CollectionPublicPath,
                target: RaceDay_NFT.CollectionStoragePath
            )
        }
        // If the account already has a RaceDay_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&RaceDay_NFT.Collection{RaceDay_NFT.RaceDay_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(RaceDay_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the RaceDay_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(RaceDay_NFT.CollectionPublicPath)

            // Create the new public capability to the RaceDay_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&RaceDay_NFT.Collection{RaceDay_NFT.RaceDay_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                RaceDay_NFT.CollectionPublicPath,
                target: RaceDay_NFT.CollectionStoragePath
            )
        }
    }
}