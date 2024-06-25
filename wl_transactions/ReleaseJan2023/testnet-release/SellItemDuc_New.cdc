import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import releasejan2023_NFT from 0x5d2efb448f701c35
import NFTStorefront from 0x94b06cfca1d8a476

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltyPercent: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let releasejan2023_NFTProvider: Capability<&releasejan2023_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
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
        let releasejan2023_NFTCollectionProviderPrivatePath = /private/releasejan2023_NFTCollectionProviderForNFTStorefront

        self.sellerPaymentReceiver = acct.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(self.sellerPaymentReceiver.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")

        if !acct.getCapability<&releasejan2023_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        (releasejan2023_NFTCollectionProviderPrivatePath)!.check() {
            acct.link<&releasejan2023_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
            (releasejan2023_NFTCollectionProviderPrivatePath, target: releasejan2023_NFT.CollectionStoragePath)
        }

        self.releasejan2023_NFTProvider = acct.getCapability<&releasejan2023_NFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(releasejan2023_NFTCollectionProviderPrivatePath)!
        assert(self.releasejan2023_NFTProvider.borrow() != nil, message: "Missing or mis-typed releasejan2023_NFT.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@releasejan2023_NFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }
    pre {
        self.gigAddress == 0x5d2efb448f701c35: "Requires valid authorizing signature"
    }
    execute {
        let amountSeller = saleItemPrice * (1.0 - royaltyPercent)
        let amountRoyalty = saleItemPrice - amountSeller

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0x6f8aa41eedff1158)

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
            nftProviderCapability: self.releasejan2023_NFTProvider,
            nftType: Type<@releasejan2023_NFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}