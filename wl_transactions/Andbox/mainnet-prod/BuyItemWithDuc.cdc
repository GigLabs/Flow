
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import Andbox_NFT from 0x329feb3ab062d289
import DapperUtilityCoin from 0xead892083b3e2c6c
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64) {
    let paymentVault: @{FungibleToken.Vault}
    let Andbox_NFTCollection: &Andbox_NFT.Collection
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
        if buyer.storage.borrow<&Andbox_NFT.Collection>(from: Andbox_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            buyer.storage.save(<-Andbox_NFT.createEmptyCollection(nftType: Type<@Andbox_NFT.NFT>()), to: Andbox_NFT.CollectionStoragePath)

            // create a public capability for the collection
            buyer.capabilities.unpublish(Andbox_NFT.CollectionPublicPath)
            let collectionCap = buyer.capabilities.storage.issue<&Andbox_NFT.Collection>(Andbox_NFT.CollectionStoragePath)
            buyer.capabilities.publish(collectionCap, at: Andbox_NFT.CollectionPublicPath)
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
        self.Andbox_NFTCollection = buyer.storage.borrow<&Andbox_NFT.Collection>(
            from: Andbox_NFT.CollectionStoragePath
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

        self.Andbox_NFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "dapperUtilityCoin leakage"
    }
}
