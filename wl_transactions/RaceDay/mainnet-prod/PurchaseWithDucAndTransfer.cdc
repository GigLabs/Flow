import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import RaceDay_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let gigNFTCollectionRef: @NonFungibleToken.Collection
  let buyerNFTCollection: &AnyResource{RaceDay_NFT.RaceDay_NFTCollectionPublic}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&RaceDay_NFT.Collection>(from: RaceDay_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-RaceDay_NFT.createEmptyCollection(), to: RaceDay_NFT.CollectionStoragePath)

        // Create a public capability to the RaceDay_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&RaceDay_NFT.Collection{NonFungibleToken.CollectionPublic,RaceDay_NFT.RaceDay_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            RaceDay_NFT.CollectionPublicPath,
            target: RaceDay_NFT.CollectionStoragePath
        )
    }
    // If the account already has a RaceDay_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if (signer.getCapability<&RaceDay_NFT.Collection{NonFungibleToken.CollectionPublic,RaceDay_NFT.RaceDay_NFTCollectionPublic,MetadataViews.ResolverCollection}>(RaceDay_NFT.CollectionPublicPath).borrow() == nil) {

        // Unlink the current capability exposing the RaceDay_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(RaceDay_NFT.CollectionPublicPath)

        // Create the new public capability to the RaceDay_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&RaceDay_NFT.Collection{NonFungibleToken.CollectionPublic,RaceDay_NFT.RaceDay_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            RaceDay_NFT.CollectionPublicPath,
            target: RaceDay_NFT.CollectionStoragePath
        )
    }
    
    // withdraw NFT
    let gigNftProvider = gig.borrow<&RaceDay_NFT.Collection>(from: RaceDay_NFT.CollectionStoragePath)
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
    .getCapability(RaceDay_NFT.CollectionPublicPath)!
    .borrow<&{RaceDay_NFT.RaceDay_NFTCollectionPublic}>()!
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x329feb3ab062d289 && sellerAddress == 0xf2d2901d91dc6611: "seller must be GigLabs"
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