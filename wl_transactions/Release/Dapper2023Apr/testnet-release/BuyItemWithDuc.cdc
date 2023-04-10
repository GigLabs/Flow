import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import dapper2023apr_NFT from 0xe168d2e4bf80d3b2
import DapperUtilityCoin from 0x82ec283f88a62e65
import NFTStorefront from 0x94b06cfca1d8a476

transaction(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let dapper2023apr_NFTCollection: &dapper2023apr_NFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let price: UFix64
    let balanceBeforeTransfer: UFix64
    let mainDapperUtilityCoinVault: &DapperUtilityCoin.Vault

    prepare(dapper: AuthAccount, buyer: AuthAccount) {
        // Initialize the buyer's collection if they do not already have one
        if buyer.borrow<&dapper2023apr_NFT.Collection>(from: dapper2023apr_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            buyer.save(<-dapper2023apr_NFT.createEmptyCollection(), to: dapper2023apr_NFT.CollectionStoragePath)

            // Create a public capability to the dapper2023apr_NFT collection
            // that exposes the Collection interface
            buyer.link<&dapper2023apr_NFT.Collection{NonFungibleToken.CollectionPublic,dapper2023apr_NFT.dapper2023apr_NFTCollectionPublic}>(
                dapper2023apr_NFT.CollectionPublicPath,
                target: dapper2023apr_NFT.CollectionStoragePath
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
        self.dapper2023apr_NFTCollection = buyer.borrow<&dapper2023apr_NFT.Collection{NonFungibleToken.Receiver}>(
            from: dapper2023apr_NFT.CollectionStoragePath
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

        self.dapper2023apr_NFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "dapperUtilityCoin leakage"
    }
}