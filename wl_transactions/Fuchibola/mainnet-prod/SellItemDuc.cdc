import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import Fuchibola_NFT from 0xf3ee684cd0259fed
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltyPercent: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let Fuchibola_NFTProvider: Capability<&Fuchibola_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(gig: AuthAccount, acct: AuthAccount) {
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
        let Fuchibola_NFTCollectionProviderPrivatePath = /private/Fuchibola_NFTCollectionProviderForNFTStorefront

        self.sellerPaymentReceiver = acct.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(self.sellerPaymentReceiver.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")

        if !acct.getCapability<&Fuchibola_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        (Fuchibola_NFTCollectionProviderPrivatePath)!.check() {
            acct.link<&Fuchibola_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
            (Fuchibola_NFTCollectionProviderPrivatePath, target: Fuchibola_NFT.CollectionStoragePath)
        }

        self.Fuchibola_NFTProvider = acct.getCapability<&Fuchibola_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(Fuchibola_NFTCollectionProviderPrivatePath)!
        assert(self.Fuchibola_NFTProvider.borrow() != nil, message: "Missing or mis-typed Fuchibola_NFT.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@Fuchibola_NFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }

    execute {
        let amountSeller = saleItemPrice * (1.0 - royaltyPercent)
        let amountRoyalty = saleItemPrice - amountSeller

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0xbdb9678b5ebc5200)

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
            nftProviderCapability: self.Fuchibola_NFTProvider,
            nftType: Type<@Fuchibola_NFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}