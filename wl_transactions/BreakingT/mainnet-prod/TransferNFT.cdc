
import NonFungibleToken from 0x1d7e57aa55817448
import BreakingT_NFT from 0x329feb3ab062d289

// This transaction is for transferring an NFT from 
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {
    // local variable for storing the transferred token
    let nft: @{NonFungibleToken.NFT}

    prepare(acct: auth(BorrowValue) &Account) {
        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.storage.borrow<auth(NonFungibleToken.Withdraw) &BreakingT_NFT.Collection>(from: BreakingT_NFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // withdraw the NFT from the owner's collection
        self.nft <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipients public account object
        let recipientAccount = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let depositRef = recipientAccount.capabilities.borrow<&BreakingT_NFT.Collection>(BreakingT_NFT.CollectionPublicPath)
            ?? panic("Could not borrow a reference to the recipient's collection")

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-self.nft)
    }
}