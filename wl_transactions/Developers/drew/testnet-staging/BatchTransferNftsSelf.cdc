import NonFungibleToken from 0x631e88ae7f1d7c20
import drewdapper_NFT from 0xf3e8f8ae2e9e2fec

// This transaction transfers all a user's NFTs from a Collection directly 
// back to the same user's account. The purpose of this transaction is 
// to re-emit withdraw and deposit events for the account so that
// 3rd party wallets and marketplaces can log token ownership 
// in cases where they weren't correctly listening to the deposit events when
// the owner originally received their tokens.
// Specifically, in some cases Dapper Wallet was not listening to certain user's
// deposit events into their wallet when tokens were received from outside
// wallets for some collections, and thus this is a band-aid solution so that
// token ownership can be correctly updated in Dapper wallet database.

transaction() {
    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's NFT collection
        let collectionRef = acct.borrow<&drewdapper_NFT.Collection>(from: drewdapper_NFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // get all owned token ids from the owner's collection
        let ids = collectionRef!.getIDs()

        // withdraw the list of NFTs from the owner's collection
        let ownerNfts <- collectionRef.batchWithdraw(ids: ids)

        // Deposit the withdrawn collection of NFTs back into the same collection
        collectionRef.batchDeposit(tokens: <-ownerNfts)
    }
}