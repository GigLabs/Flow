
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xGENERAL_FUNGIBLE_ADDRESS
import Bobblz_NFT from 0xd45e2bd9a3d5003b
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltyPercent: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let Bobblz_NFTProvider: Capability<auth(NonFungibleToken.Withdraw) &Bobblz_NFT.Collection>
    let storefront: auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront
    let gigAddress: Address

    prepare(gig: &Account, acct: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        self.gigAddress = gig.address
        // If the account doesn't already have a Storefront
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

        if acct.storage.borrow<&Bobblz_NFT.Collection>(from: Bobblz_NFT.CollectionStoragePath) == nil {
            let collectionCap = acct.capabilities.storage.issue<&Bobblz_NFT.Collection>(Bobblz_NFT.CollectionStoragePath)
            acct.capabilities.publish(collectionCap, at: Bobblz_NFT.CollectionPublicPath)
        }

        self.Bobblz_NFTProvider = acct.capabilities.get<auth(NonFungibleToken.Withdraw) &Bobblz_NFT.Collection>(Bobblz_NFT.CollectionPublicPath)
        assert(self.Bobblz_NFTProvider.borrow() != nil, message: "Missing or mis-typed Bobblz_NFT.Collection provider")

        self.storefront = acct.storage.borrow<auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@Bobblz_NFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }

    pre {
        self.gigAddress == 0xd45e2bd9a3d5003b: "Requires valid authorizing signature"
    }
    execute {
        let amountSeller = saleItemPrice * (1.0 - royaltyPercent)
        let amountRoyalty = saleItemPrice - amountSeller

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0xb82ba4137573164c)

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
            nftProviderCapability: self.Bobblz_NFTProvider,
            nftType: Type<@Bobblz_NFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}