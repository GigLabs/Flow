
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0xGENERAL_FUNGIBLE_ADDRESS
import roguebunnies_NFT from 0x04625c28593d9408
import NFTStorefront from 0x94b06cfca1d8a476

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltyPercent: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let roguebunnies_NFTProvider: Capability<auth(NonFungibleToken.Withdraw) &roguebunnies_NFT.Collection>
    let storefront: auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront

    prepare(gig: &Account, acct: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        if acct.storage.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {

            // Create a new empty .Storefront
            let storefront <- NFTStorefront.createStorefront()
            
            // save it to the account
            acct.storage.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)

            // create a public capability for the .Storefront
            acct.capabilities.unpublish(NFTStorefront.StorefrontPublicPath)
            let storefrontCap = acct.capabilities.storage.issue<&NFTStorefront.Storefront>(NFTStorefront.StorefrontStoragePath)
            acct.capabilities.publish(storefrontCap, at: NFTStorefront.StorefrontPublicPath)
        }

        self.sellerPaymentReceiver = acct.capabilities.get<&{FungibleToken.Receiver}>(DapperUtilityCoin.ReceiverPublicPath)
        assert(self.sellerPaymentReceiver.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")

        self.roguebunnies_NFTProvider = acct.capabilities.storage.issue<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(roguebunnies_NFT.CollectionStoragePath)
        assert(self.roguebunnies_NFTProvider.check(), message: "Missing or mis-typed roguebunnies_NFT.Collection provider")

        self.storefront = acct.storage.borrow<auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@roguebunnies_NFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }

    execute {
        let amountSeller = saleItemPrice * (1.0 - royaltyPercent)
        let amountRoyalty = saleItemPrice - amountSeller

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0x6f8aa41eedff1158)

        // Get a reference to the royalty recipient's Receiver
        let royaltyReceiverRef = royaltyRecipient.capabilities.get<&{FungibleToken.Receiver}>(DapperUtilityCoin.ReceiverPublicPath)
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
            nftProviderCapability: self.roguebunnies_NFTProvider,
            nftType: Type<@roguebunnies_NFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}