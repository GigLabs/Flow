
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0xGENERAL_FUNGIBLE_ADDRESS
import daptik_NFT from 0x18f64cc2a32091a3
import NFTStorefront from 0x94b06cfca1d8a476

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltyPercent: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let daptik_NFTProvider: Capability<auth(NonFungibleToken.Withdraw) &daptik_NFT.Collection>
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

        self.sellerPaymentReceiver = acct.capabilities.get<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(self.sellerPaymentReceiver.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")

        if acct.storage.borrow<&daptik_NFT.Collection>(from: daptik_NFT.CollectionStoragePath) == nil {
            let collectionCap = acct.capabilities.storage.issue<&daptik_NFT.Collection>(daptik_NFT.CollectionStoragePath)
            acct.capabilities.publish(collectionCap, at: daptik_NFT.CollectionPublicPath)
        }

        self.daptik_NFTProvider = acct.capabilities.get<auth(NonFungibleToken.Withdraw) &daptik_NFT.Collection>(daptik_NFT.CollectionPublicPath)
        assert(self.daptik_NFTProvider.borrow() != nil, message: "Missing or mis-typed daptik_NFT.Collection provider")

        self.storefront = acct.storage.borrow<auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@daptik_NFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }

    pre {
        self.gigAddress == 0x18f64cc2a32091a3: "Requires valid authorizing signature"
    }
    execute {
        let amountSeller = saleItemPrice * (1.0 - royaltyPercent)
        let amountRoyalty = saleItemPrice - amountSeller

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0xa60a22bbd219e76b)

        // Get a reference to the royalty recipient's Receiver
        let royaltyReceiverRef = royaltyRecipient.capabilities.get<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
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
            nftProviderCapability: self.daptik_NFTProvider,
            nftType: Type<@daptik_NFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}