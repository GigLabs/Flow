import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import CNN_INT_NFT from 0x04625c28593d9408
import DapperUtilityCoin from 0x82ec283f88a62e65
import NFTStorefront from 0x94b06cfca1d8a476

transaction(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let CNN_INT_NFTCollection: &CNN_INT_NFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let price: UFix64
    let balanceBeforeTransfer: UFix64
    let mainDapperUtilityCoinVault: &DapperUtilityCoin.Vault

    prepare(dapper: AuthAccount, buyer: AuthAccount) {
        // Initialize the buyer's collection if they do not already have one
        if buyer.borrow<&CNN_INT_NFT.Collection>(from: CNN_INT_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            buyer.save(<-CNN_INT_NFT.createEmptyCollection(), to: CNN_INT_NFT.CollectionStoragePath)

            // Create a public capability to the CNN_INT_NFT collection
            // that exposes the Collection interface
            buyer.link<&CNN_INT_NFT.Collection{NonFungibleToken.CollectionPublic,CNN_INT_NFT.CNN_INT_NFTCollectionPublic}>(
                CNN_INT_NFT.CollectionPublicPath,
                target: CNN_INT_NFT.CollectionStoragePath
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
        self.CNN_INT_NFTCollection = buyer.borrow<&CNN_INT_NFT.Collection{NonFungibleToken.Receiver}>(
            from: CNN_INT_NFT.CollectionStoragePath
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

        self.CNN_INT_NFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "dapperUtilityCoin leakage"
    }
}