import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import UFC_NFT from 0x329feb3ab062d289
import MetadataViews from 0x8f9bd747571ebdf4

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let gigNFTCollectionRef: @NonFungibleToken.Collection
  let buyerNFTCollection: &AnyResource{UFC_NFT.UFC_NFTCollectionPublic}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&UFC_NFT.Collection>(from: UFC_NFT.CollectionStoragePath) == nil {

      // Create a new empty collection and save it to the account
      buyer.save(<-UFC_NFT.createEmptyCollection(), to: UFC_NFT.CollectionStoragePath)

      // Create a public capability to the UFC_NFT collection
      // that exposes the Collection interface, which now includes
      // the Metadata Resolver to expose Metadata Standard views
      buyer.link<&UFC_NFT.Collection{NonFungibleToken.CollectionPublic,UFC_NFT.UFC_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
          UFC_NFT.CollectionPublicPath,
          target: UFC_NFT.CollectionStoragePath
      )
  }
  // If the account already has a UFC_NFT collection, but has not yet exposed the 
  // Metadata Resolver interface for the Metadata Standard views
  else if !buyer.getCapability<&UFC_NFT.Collection{NonFungibleToken.CollectionPublic,UFC_NFT.UFC_NFTCollectionPublic,MetadataViews.ResolverCollection}>
      (UFC_NFT.CollectionPublicPath)!.check() { 

      // Unlink the current capability exposing the UFC_NFT collection,
      // as it needs to be replaced with an updated capability
      buyer.unlink(UFC_NFT.CollectionPublicPath)

      // Create the new public capability to the UFC_NFT collection
      // that exposes the Collection interface, which now includes
      // the Metadata Resolver to expose Metadata Standard views
      buyer.link<&UFC_NFT.Collection{NonFungibleToken.CollectionPublic,UFC_NFT.UFC_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
          UFC_NFT.CollectionPublicPath,
          target: UFC_NFT.CollectionStoragePath
      )
  }
    
    // withdraw NFT
    let gigNftProvider = gig.borrow<&UFC_NFT.Collection>(from: UFC_NFT.CollectionStoragePath)
        ?? panic("Could not borrow NFT Provider")
    self.gigNFTCollectionRef <- gigNftProvider.batchWithdraw(ids: nftIDs)
    // withdraw DUC
    self.mainDucVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
        ?? panic("Could not borrow reference to Dapper Utility Coin vault")
    self.balanceBeforeTransfer = self.mainDucVault.balance
    self.paymentVault <- self.mainDucVault.withdraw(amount: price)
    // set seller DUC receiver ref
    self.sellerPaymentReceiver = getAccount(sellerAddress).getCapability(/public/dapperUtilityCoinReceiver)
    .borrow<&{FungibleToken.Receiver}>()
    ?? panic("Could not borrow receiver reference to the recipient's Vault")
    // set buyer NFT receiver ref
    self.buyerNFTCollection = buyer
    .getCapability(UFC_NFT.CollectionPublicPath)!
    .borrow<&{UFC_NFT.UFC_NFTCollectionPublic}>()!
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x329feb3ab062d289 && sellerAddress == 0xcfa0d15914188d1d: "seller must be GigLabs"
  }
  execute {
    self.sellerPaymentReceiver.deposit(from: <- self.paymentVault)
    self.buyerNFTCollection.batchDeposit(tokens: <-self.gigNFTCollectionRef)
  }
  post {
    // Ensure there is no DUC leakage
    self.mainDucVault.balance == self.balanceBeforeTransfer:
        "transaction would leak DUC"
  }
}