import FungibleToken from 
import NonFungibleToken from 
import DapperUtilityCoin from 0xDUC_CONTRACT_ADDRESS
import GigLabsQA_NFT from 

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&GigLabsQA_NFT.Collection>(from: GigLabsQA_NFT.CollectionStoragePath) == nil {
        // Create a new empty collection and save it to the account
        buyer.save(<-GigLabsQA_NFT.createEmptyCollection(), to: GigLabsQA_NFT.CollectionStoragePath)
        // Create a public capability to the GigLabsQA_NFT collection
        // that exposes the Collection interface
        buyer.link<&GigLabsQA_NFT.Collection{NonFungibleToken.CollectionPublic,GigLabsQA_NFT.GigLabsQA_NFTCollectionPublic}>(
            GigLabsQA_NFT.CollectionPublicPath,
            target: GigLabsQA_NFT.CollectionStoragePath
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
    self.gigAuthAccountAddress ==  && sellerAddress == 0x6f8aa41eedff1158: "seller must be GigLabs"
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