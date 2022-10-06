import NonFungibleToken from 0x1d7e57aa55817448
import Bobblz_NFT from 0xd45e2bd9a3d5003b
import MetadataViews from 0x1d7e57aa55817448

// This transaction installs the Bobblz_NFT collection so an
// account can receive Bobblz_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&Bobblz_NFT.Collection>(from: Bobblz_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-Bobblz_NFT.createEmptyCollection(), to: Bobblz_NFT.CollectionStoragePath)

            // Create a public capability to the Bobblz_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Bobblz_NFT.Collection{Bobblz_NFT.Bobblz_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Bobblz_NFT.CollectionPublicPath,
                target: Bobblz_NFT.CollectionStoragePath
            )
        }
        // If the account already has a Bobblz_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&Bobblz_NFT.Collection{Bobblz_NFT.Bobblz_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(Bobblz_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the Bobblz_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(Bobblz_NFT.CollectionPublicPath)

            // Create the new public capability to the Bobblz_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&Bobblz_NFT.Collection{Bobblz_NFT.Bobblz_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                Bobblz_NFT.CollectionPublicPath,
                target: Bobblz_NFT.CollectionStoragePath
            )
        }
    }
}