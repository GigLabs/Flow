
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import daptik_NFT from 0x18f64cc2a32091a3
import DapperUtilityCoin from 0x82ec283f88a62e65
import NFTStorefront from 0x94b06cfca1d8a476

transaction(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64) {
    let paymentVault: @{FungibleToken.Vault}
    let daptik_NFTCollection: &daptik_NFT.Collection
    let storefront: &NFTStorefront.Storefront
    let listing: &{NFTStorefront.ListingPublic}
    let price: UFix64
    let balanceBeforeTransfer: UFix64
    let mainDapperUtilityCoinVault: auth(FungibleToken.Withdraw) &DapperUtilityCoin.Vault

    prepare(
        dapper: auth(BorrowValue) &Account,
        buyer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account
    ) {
        // Initialize the buyer's collection if they do not already have one
        if buyer.storage.borrow<&daptik_NFT.Collection>(from: daptik_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            buyer.storage.save(<-daptik_NFT.createEmptyCollection(nftType: Type<@daptik_NFT.NFT>()), to: daptik_NFT.CollectionStoragePath)

            // create a public capability for the collection
            buyer.capabilities.unpublish(daptik_NFT.CollectionPublicPath)
            let collectionCap = buyer.capabilities.storage.issue<&daptik_NFT.Collection>(daptik_NFT.CollectionStoragePath)
            buyer.capabilities.publish(collectionCap, at: daptik_NFT.CollectionPublicPath)
        }

        // Get the storefront reference from the seller
        self.storefront = getAccount(storefrontAddress)
            .capabilities.borrow<&NFTStorefront.Storefront>(
                NFTStorefront.StorefrontPublicPath
            )
            ?? panic("Could not borrow Storefront from provided address")

        // Get the listing by ID from the storefront
        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        self.price = self.listing.getDetails().salePrice

        // Withdraw mainDapperUtilityCoinVault from Dapper's account
        self.mainDapperUtilityCoinVault = dapper.storage.borrow<auth(FungibleToken.Withdraw) &DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
            ?? panic("Cannot borrow DapperUtilityCoin vault from account storage")
        self.balanceBeforeTransfer = self.mainDapperUtilityCoinVault.balance
        self.paymentVault <- self.mainDapperUtilityCoinVault.withdraw(amount: self.price)

        // Get the collection from the buyer so the NFT can be deposited into it
        self.daptik_NFTCollection = buyer.storage.borrow<&daptik_NFT.Collection>(
            from: daptik_NFT.CollectionStoragePath
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    // Check that the price is right
    pre {
        self.price == expectedPrice: "unexpected price"
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.daptik_NFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "dapperUtilityCoin leakage"
    }
}
