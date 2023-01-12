import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import BWAYX_NFT from 0xf02b15e11eb3715b
import MetadataViews from 0x1d7e57aa55817448

transaction(sellerAddress: Address, orderUuid: String, price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&BWAYX_NFT.Collection>(from: BWAYX_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-BWAYX_NFT.createEmptyCollection(), to: BWAYX_NFT.CollectionStoragePath)

        // Create a public capability to the BWAYX_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&BWAYX_NFT.Collection{BWAYX_NFT.BWAYX_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            BWAYX_NFT.CollectionPublicPath,
            target: BWAYX_NFT.CollectionStoragePath
        )
    }
    // If the account already has a BWAYX_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if (buyer.getCapability<&BWAYX_NFT.Collection{BWAYX_NFT.BWAYX_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(BWAYX_NFT.CollectionPublicPath).borrow() == nil) {

        // Unlink the current capability exposing the BWAYX_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(BWAYX_NFT.CollectionPublicPath)

        // Create the new public capability to the BWAYX_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&BWAYX_NFT.Collection{BWAYX_NFT.BWAYX_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            BWAYX_NFT.CollectionPublicPath,
            target: BWAYX_NFT.CollectionStoragePath
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
    self.gigAuthAccountAddress == 0xf02b15e11eb3715b && sellerAddress == 0xb82ba4137573164c: "seller must be GigLabs"
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