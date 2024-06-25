import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import AtlantaHawks_NFT from 0x14c2f30a9e2e923f
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltyPercent: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let AtlantaHawks_NFTProvider: Capability<&AtlantaHawks_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let gigAddress: Address

    prepare(gig: AuthAccount, acct: AuthAccount) {
        self.gigAddress = gig.address
        // If the account doesn't already have a Storefront
        if acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {

            // Create a new empty .Storefront
            let newstorefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront
            
            // save it to the account
            acct.save(<-newstorefront, to: NFTStorefront.StorefrontStoragePath)

            // create a public capability for the .Storefront
            acct.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath,
                target: NFTStorefront.StorefrontStoragePath
            )
        }

        // We need a provider capability, but one is not provided by default so we create one if needed.
        let AtlantaHawks_NFTCollectionProviderPrivatePath = /private/AtlantaHawks_NFTCollectionProviderForNFTStorefront

        self.sellerPaymentReceiver = acct.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(self.sellerPaymentReceiver.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")

        if !acct.getCapability<&AtlantaHawks_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        (AtlantaHawks_NFTCollectionProviderPrivatePath)!.check() {
            acct.link<&AtlantaHawks_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
            (AtlantaHawks_NFTCollectionProviderPrivatePath, target: AtlantaHawks_NFT.CollectionStoragePath)
        }

        self.AtlantaHawks_NFTProvider = acct.getCapability<&AtlantaHawks_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(AtlantaHawks_NFTCollectionProviderPrivatePath)!
        assert(self.AtlantaHawks_NFTProvider.borrow() != nil, message: "Missing or mis-typed AtlantaHawks_NFT.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@AtlantaHawks_NFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }
    pre {
        self.gigAddress == 0x14c2f30a9e2e923f: "Requires valid authorizing signature"
    }
    execute {
        let amountSeller = saleItemPrice * (1.0 - royaltyPercent)
        let amountRoyalty = saleItemPrice - amountSeller

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0x445f50cc9ce70db9)

        // Get a reference to the royalty recipient's Receiver
        let royaltyReceiverRef = royaltyRecipient.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(royaltyReceiverRef.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin royalty receiver")

        let saleCutSeller = NFTStorefront.SaleCut(
            receiver: self.sellerPaymentReceiver,
            amount: amountSeller
        )

        let saleCutRoyalty = NFTStorefront.SaleCut(
            receiver: royaltyReceiverRef,
            amount: amountRoyalty
        )

        self.storefront.createListing(
            nftProviderCapability: self.AtlantaHawks_NFTProvider,
            nftType: Type<@AtlantaHawks_NFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}