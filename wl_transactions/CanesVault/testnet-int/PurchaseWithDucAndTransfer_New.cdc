import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import Canes_Vault_Int_NFT from 0x04625c28593d9408
import MetadataViews from 0x9b053ed2bd3e7339

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let gigNFTCollectionRef: @NonFungibleToken.Collection
  let buyerNFTCollection: &AnyResource{Canes_Vault_Int_NFT.Canes_Vault_Int_NFTCollectionPublic}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&Canes_Vault_Int_NFT.Collection>(from: Canes_Vault_Int_NFT.CollectionStoragePath) == nil {

      // Create a new empty collection and save it to the account
      buyer.save(<-Canes_Vault_Int_NFT.createEmptyCollection(), to: Canes_Vault_Int_NFT.CollectionStoragePath)

      // Create a public capability to the Canes_Vault_Int_NFT collection
      // that exposes the Collection interface, which now includes
      // the Metadata Resolver to expose Metadata Standard views
      buyer.link<&Canes_Vault_Int_NFT.Collection{NonFungibleToken.CollectionPublic,Canes_Vault_Int_NFT.Canes_Vault_Int_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
          Canes_Vault_Int_NFT.CollectionPublicPath,
          target: Canes_Vault_Int_NFT.CollectionStoragePath
      )
  }
  // If the account already has a Canes_Vault_Int_NFT collection, but has not yet exposed the 
  // Metadata Resolver interface for the Metadata Standard views
  else if !buyer.getCapability<&Canes_Vault_Int_NFT.Collection{NonFungibleToken.CollectionPublic,Canes_Vault_Int_NFT.Canes_Vault_Int_NFTCollectionPublic,MetadataViews.ResolverCollection}>
      (Canes_Vault_Int_NFT.CollectionPublicPath)!.check() { 

      // Unlink the current capability exposing the Canes_Vault_Int_NFT collection,
      // as it needs to be replaced with an updated capability
      buyer.unlink(Canes_Vault_Int_NFT.CollectionPublicPath)

      // Create the new public capability to the Canes_Vault_Int_NFT collection
      // that exposes the Collection interface, which now includes
      // the Metadata Resolver to expose Metadata Standard views
      buyer.link<&Canes_Vault_Int_NFT.Collection{NonFungibleToken.CollectionPublic,Canes_Vault_Int_NFT.Canes_Vault_Int_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
          Canes_Vault_Int_NFT.CollectionPublicPath,
          target: Canes_Vault_Int_NFT.CollectionStoragePath
      )
  }
    
    // withdraw NFT
    let gigNftProvider = gig.borrow<&Canes_Vault_Int_NFT.Collection>(from: Canes_Vault_Int_NFT.CollectionStoragePath)
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
    .getCapability(Canes_Vault_Int_NFT.CollectionPublicPath)!
    .borrow<&{Canes_Vault_Int_NFT.Canes_Vault_Int_NFTCollectionPublic}>()!
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x04625c28593d9408 && sellerAddress == 0x564ad491cb42301c: "seller must be GigLabs"
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