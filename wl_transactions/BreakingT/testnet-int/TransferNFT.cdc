import NonFungibleToken from 0x631e88ae7f1d7c20
import BreakingT_NFT from 0x04625c28593d9408

// This transaction is for transferring an NFT from 
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {
    // local variable for storing the transferred token
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.borrow<&BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // withdraw the NFT from the owner's collection
        self.nft <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipients public account object
        let recipientAccount = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let depositRef = recipientAccount.getCapability(BreakingT_NFT.CollectionPublicPath)!.borrow<&{BreakingT_NFT.BreakingT_NFTCollectionPublic}>()!

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-self.nft)
    }
}