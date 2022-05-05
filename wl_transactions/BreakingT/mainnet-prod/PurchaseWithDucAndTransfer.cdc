import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import BreakingT_NFT from 0x329feb3ab062d289

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let gigNFTCollectionRef: @NonFungibleToken.Collection
  let buyerNFTCollection: &AnyResource{BreakingT_NFT.BreakingT_NFTCollectionPublic}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath) == nil {
        // Create a new empty collection and save it to the account
        buyer.save(<-BreakingT_NFT.createEmptyCollection(), to: BreakingT_NFT.CollectionStoragePath)
        // Create a public capability to the BreakingT_NFT collection
        // that exposes the Collection interface
        buyer.link<&BreakingT_NFT.Collection{NonFungibleToken.CollectionPublic,BreakingT_NFT.BreakingT_NFTCollectionPublic}>(
            BreakingT_NFT.CollectionPublicPath,
            target: BreakingT_NFT.CollectionStoragePath
        )
    }
    
    // withdraw NFT
    let gigNftProvider = gig.borrow<&BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath)
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
    .getCapability(BreakingT_NFT.CollectionPublicPath)!
    .borrow<&{BreakingT_NFT.BreakingT_NFTCollectionPublic}>()!
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x329feb3ab062d289 && sellerAddress == 0xdb05f5392d1da535: "seller must be GigLabs"
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