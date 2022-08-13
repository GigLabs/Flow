import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import Cimelio_NFT from 0x2c9de937c319468d
import MetadataViews from 0x8f9bd747571ebdf4

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&Cimelio_NFT.Collection>(from: Cimelio_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-Cimelio_NFT.createEmptyCollection(), to: Cimelio_NFT.CollectionStoragePath)

        // Create a public capability to the Cimelio_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&Cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,Cimelio_NFT.Cimelio_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            Cimelio_NFT.CollectionPublicPath,
            target: Cimelio_NFT.CollectionStoragePath
        )
    }
    // If the account already has a Cimelio_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if !buyer.getCapability<&Cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,Cimelio_NFT.Cimelio_NFTCollectionPublic,MetadataViews.ResolverCollection}>
        (Cimelio_NFT.CollectionPublicPath)!.check() { 

        // Unlink the current capability exposing the Cimelio_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(Cimelio_NFT.CollectionPublicPath)

        // Create the new public capability to the Cimelio_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&Cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,Cimelio_NFT.Cimelio_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            Cimelio_NFT.CollectionPublicPath,
            target: Cimelio_NFT.CollectionStoragePath
        )
    }
    
    // withdraw DUC
    self.mainDucVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
        ?? panic("Could not borrow reference to Dapper Utility Coin vault")
    self.balanceBeforeTransfer = self.mainDucVault.balance
    self.paymentVault <- self.mainDucVault.withdraw(amount: price)
    // set seller DUC receiver ref
    self.sellerPaymentReceiver = getAccount(sellerAddress).getCapability(/public/dapperUtilityCoinReceiver)
    .borrow<&{FungibleToken.Receiver}>()
    ?? panic("Could not borrow receiver reference to the recipient's Vault")
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x2c9de937c319468d && sellerAddress == 0x56b610f9c0dbf02b: "seller must be GigLabs"
  }
  execute {
    self.sellerPaymentReceiver.deposit(from: <- self.paymentVault)
  }
  post {
    // Ensure there is no DUC leakage
    self.mainDucVault.balance == self.balanceBeforeTransfer:
        "transaction would leak DUC"
  }
}