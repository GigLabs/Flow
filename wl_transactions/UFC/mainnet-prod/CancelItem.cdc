import NFTStorefront from 0x4eb8a10cb9f87357

// UFC_NFT
transaction(listingResourceID: UInt64) {
    let storefront: auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront

    prepare(acct: auth(BorrowValue) &Account) {
        self.storefront = acct.storage.borrow<auth(NFTStorefront.RemoveListing, NFTStorefront.CreateListing) &NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront.Storefront")
    }

    execute {
        self.storefront.removeListing(listingResourceID: listingResourceID)
    }
}