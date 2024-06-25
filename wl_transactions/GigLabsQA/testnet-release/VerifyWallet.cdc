import NonFungibleToken from 0x631e88ae7f1d7c20
import GigLabsQA_NFT from 0x18445fd03b683069
import MetadataViews from 0x631e88ae7f1d7c20

// This transaction installs the GigLabsQA_NFT collection so an
// account can receive GigLabsQA_NFT NFTs 

transaction(verificationToken: String) {
    prepare(signer: AuthAccount) {

        // If the account doesn't already have a collection
        if signer.borrow<&GigLabsQA_NFT.Collection>(from: GigLabsQA_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            signer.save(<-GigLabsQA_NFT.createEmptyCollection(), to: GigLabsQA_NFT.CollectionStoragePath)

            // Create a public capability to the GigLabsQA_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&GigLabsQA_NFT.Collection{GigLabsQA_NFT.GigLabsQA_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                GigLabsQA_NFT.CollectionPublicPath,
                target: GigLabsQA_NFT.CollectionStoragePath
            )
        }
        // If the account already has a GigLabsQA_NFT collection, but has not yet exposed the 
        // Metadata Resolver interface for the Metadata Standard views
        else if (signer.getCapability<&GigLabsQA_NFT.Collection{GigLabsQA_NFT.GigLabsQA_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(GigLabsQA_NFT.CollectionPublicPath).borrow() == nil) {

            // Unlink the current capability exposing the GigLabsQA_NFT collection,
            // as it needs to be replaced with an updated capability
            signer.unlink(GigLabsQA_NFT.CollectionPublicPath)

            // Create the new public capability to the GigLabsQA_NFT collection
            // that exposes the Collection interface, which now includes
            // the Metadata Resolver to expose Metadata Standard views
            signer.link<&GigLabsQA_NFT.Collection{GigLabsQA_NFT.GigLabsQA_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                GigLabsQA_NFT.CollectionPublicPath,
                target: GigLabsQA_NFT.CollectionStoragePath
            )
        }
    }
}