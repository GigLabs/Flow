
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import drewdapper_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x631e88ae7f1d7c20

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let gigNFTCollectionRef: @NonFungibleToken.Collection
  let buyerNFTCollection: &AnyResource{drewdapper_NFT.drewdapper_NFTCollectionPublic}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&drewdapper_NFT.Collection>(from: drewdapper_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-drewdapper_NFT.createEmptyCollection(), to: drewdapper_NFT.CollectionStoragePath)

        // Create a public capability to the drewdapper_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&drewdapper_NFT.Collection{drewdapper_NFT.drewdapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            drewdapper_NFT.CollectionPublicPath,
            target: drewdapper_NFT.CollectionStoragePath
        )
    }
    // If the account already has a drewdapper_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if (buyer.getCapability<&drewdapper_NFT.Collection{drewdapper_NFT.drewdapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(drewdapper_NFT.CollectionPublicPath).borrow() == nil) {

        // Unlink the current capability exposing the drewdapper_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(drewdapper_NFT.CollectionPublicPath)

        // Create the new public capability to the drewdapper_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&drewdapper_NFT.Collection{drewdapper_NFT.drewdapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            drewdapper_NFT.CollectionPublicPath,
            target: drewdapper_NFT.CollectionStoragePath
        )
    }
    
    // withdraw NFT
    let gigNftProvider = gig.borrow<&drewdapper_NFT.Collection>(from: drewdapper_NFT.CollectionStoragePath)
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
    .getCapability(drewdapper_NFT.CollectionPublicPath)!
    .borrow<&{drewdapper_NFT.drewdapper_NFTCollectionPublic}>()!
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0xf3e8f8ae2e9e2fec && sellerAddress == 0xa60a22bbd219e76b: "seller must be GigLabs"
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