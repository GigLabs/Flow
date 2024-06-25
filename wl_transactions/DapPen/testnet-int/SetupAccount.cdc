import NonFungibleToken from 0x631e88ae7f1d7c20
import DapPen_NFT from 0x1df9c41532276279
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the DapPen_NFT collection so an
// account can receive DapPen_NFT NFTs 

transaction() {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&DapPen_NFT.Collection>(from: DapPen_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-DapPen_NFT.createEmptyCollection(), to: DapPen_NFT.CollectionStoragePath)

            // Create a public capability to the DapPen_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&DapPen_NFT.Collection{DapPen_NFT.DapPen_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                DapPen_NFT.CollectionPublicPath,
                target: DapPen_NFT.CollectionStoragePath
            )
        }
        // If the account already has a DapPen_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&DapPen_NFT.Collection{DapPen_NFT.DapPen_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(DapPen_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the DapPen_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(DapPen_NFT.CollectionPublicPath)

            // Create the new public capability to the DapPen_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&DapPen_NFT.Collection{DapPen_NFT.DapPen_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                DapPen_NFT.CollectionPublicPath,
                target: DapPen_NFT.CollectionStoragePath
            )
        }
    }
}