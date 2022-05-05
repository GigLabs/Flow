import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import Cimelio_NFT from 0x2c9de937c319468d
import DapperUtilityCoin from 0xead892083b3e2c6c
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(listingResourceID: UInt64, storefrontAddress: Address, expectedPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let Cimelio_NFTCollection: &Cimelio_NFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let price: UFix64
    let balanceBeforeTransfer: UFix64
    let mainDapperUtilityCoinVault: &DapperUtilityCoin.Vault

    prepare(dapper: AuthAccount, buyer: AuthAccount) {
        // Initialize the buyer's collection if they do not already have one
        if buyer.borrow<&Cimelio_NFT.Collection>(from: Cimelio_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            buyer.save(<-Cimelio_NFT.createEmptyCollection(), to: Cimelio_NFT.CollectionStoragePath)

            // Create a public capability to the Cimelio_NFT collection
            // that exposes the Collection interface
            buyer.link<&Cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,Cimelio_NFT.Cimelio_NFTCollectionPublic}>(
                Cimelio_NFT.CollectionPublicPath,
                target: Cimelio_NFT.CollectionStoragePath
            )
        }

        // Get the storefront reference from the seller
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        // Get the listing by ID from the storefront
        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        self.price = self.listing.getDetails().salePrice

        // Withdraw mainDapperUtilityCoinVault from Dapper's account
        self.mainDapperUtilityCoinVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
            ?? panic("Cannot borrow DapperUtilityCoin vault from account storage")
        self.balanceBeforeTransfer = self.mainDapperUtilityCoinVault.balance
        self.paymentVault <- self.mainDapperUtilityCoinVault.withdraw(amount: self.price)

        // Get the collection from the buyer so the NFT can be deposited into it
        self.Cimelio_NFTCollection = buyer.borrow<&Cimelio_NFT.Collection{NonFungibleToken.Receiver}>(
            from: Cimelio_NFT.CollectionStoragePath
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

        self.Cimelio_NFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "dapperUtilityCoin leakage"
    }
}