import NonFungibleToken from 0x631e88ae7f1d7c20
import drewdapper_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the drewdapper_NFT collection so an
// account can receive drewdapper_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&drewdapper_NFT.Collection>(from: drewdapper_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-drewdapper_NFT.createEmptyCollection(), to: drewdapper_NFT.CollectionStoragePath)

            // Create a public capability to the drewdapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&drewdapper_NFT.Collection{NonFungibleToken.CollectionPublic,drewdapper_NFT.drewdapper_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                drewdapper_NFT.CollectionPublicPath,
                target: drewdapper_NFT.CollectionStoragePath
            )
        }
        // If the account already has a drewdapper_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if !signer.getCapability<&drewdapper_NFT.Collection{NonFungibleToken.CollectionPublic,drewdapper_NFT.drewdapper_NFTCollectionPublic,MetadataViews.ResolverCollection}>
            (drewdapper_NFT.CollectionPublicPath)!.check() { 

            // Unlink the current capability exposing the drewdapper_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(drewdapper_NFT.CollectionPublicPath)

            // Create the new public capability to the drewdapper_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&drewdapper_NFT.Collection{NonFungibleToken.CollectionPublic,drewdapper_NFT.drewdapper_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
                drewdapper_NFT.CollectionPublicPath,
                target: drewdapper_NFT.CollectionStoragePath
            )
        }
    }
}