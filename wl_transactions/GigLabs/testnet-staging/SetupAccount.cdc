import NonFungibleToken from 0x631e88ae7f1d7c20
import giglabs_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the giglabs_NFT collection so an
// account can receive giglabs_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&giglabs_NFT.Collection>(from: giglabs_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-giglabs_NFT.createEmptyCollection(), to: giglabs_NFT.CollectionStoragePath)

            // Create a public capability to the giglabs_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&giglabs_NFT.Collection{giglabs_NFT.giglabs_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                giglabs_NFT.CollectionPublicPath,
                target: giglabs_NFT.CollectionStoragePath
            )
        }
        // If the account already has a giglabs_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&giglabs_NFT.Collection{giglabs_NFT.giglabs_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(giglabs_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the giglabs_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(giglabs_NFT.CollectionPublicPath)

            // Create the new public capability to the giglabs_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&giglabs_NFT.Collection{giglabs_NFT.giglabs_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                giglabs_NFT.CollectionPublicPath,
                target: giglabs_NFT.CollectionStoragePath
            )
        }
    }
}