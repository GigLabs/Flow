import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import AtlantaHawks_NFT from 0x14c2f30a9e2e923f
import MetadataViews from 0x8f9bd747571ebdf4

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let gigNFTCollectionRef: @NonFungibleToken.Collection
  let buyerNFTCollection: &AnyResource{AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&AtlantaHawks_NFT.Collection>(from: AtlantaHawks_NFT.CollectionStoragePath) == nil {

      // Create a new empty collection and save it to the account
      buyer.save(<-AtlantaHawks_NFT.createEmptyCollection(), to: AtlantaHawks_NFT.CollectionStoragePath)

      // Create a public capability to the AtlantaHawks_NFT collection
      // that exposes the Collection interface, which now includes
      // the Metadata Resolver to expose Metadata Standard views
      buyer.link<&AtlantaHawks_NFT.Collection{NonFungibleToken.CollectionPublic,AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
          AtlantaHawks_NFT.CollectionPublicPath,
          target: AtlantaHawks_NFT.CollectionStoragePath
      )
  }
  // If the account already has a AtlantaHawks_NFT collection, but has not yet exposed the 
  // Metadata Resolver interface for the Metadata Standard views
  else if !buyer.getCapability<&AtlantaHawks_NFT.Collection{NonFungibleToken.CollectionPublic,AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic,MetadataViews.ResolverCollection}>
      (AtlantaHawks_NFT.CollectionPublicPath)!.check() { 

      // Unlink the current capability exposing the AtlantaHawks_NFT collection,
      // as it needs to be replaced with an updated capability
      buyer.unlink(AtlantaHawks_NFT.CollectionPublicPath)

      // Create the new public capability to the AtlantaHawks_NFT collection
      // that exposes the Collection interface, which now includes
      // the Metadata Resolver to expose Metadata Standard views
      buyer.link<&AtlantaHawks_NFT.Collection{NonFungibleToken.CollectionPublic,AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
          AtlantaHawks_NFT.CollectionPublicPath,
          target: AtlantaHawks_NFT.CollectionStoragePath
      )
  }
    
    // withdraw NFT
    let gigNftProvider = gig.borrow<&AtlantaHawks_NFT.Collection>(from: AtlantaHawks_NFT.CollectionStoragePath)
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
    .getCapability(AtlantaHawks_NFT.CollectionPublicPath)!
    .borrow<&{AtlantaHawks_NFT.AtlantaHawks_NFTCollectionPublic}>()!
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x14c2f30a9e2e923f && sellerAddress == 0x445f50cc9ce70db9: "seller must be GigLabs"
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