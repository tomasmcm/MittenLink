import { ethers } from 'ethers'
import { parseTransaction } from '../utils'

import MittenLink from '../out/MittenLink.sol/MittenLink.metadata.json'

(async () =>{
  // Initialise provider, wallet and contract
  const provider = new ethers.providers.InfuraProvider(process.env.INFURA_ENV, process.env.INFURA_KEY);

  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  const mittenLink = new ethers.Contract(
    process.env.CONTRACT_ADDRESS,
    MittenLink.abi,
    wallet
  )

  // Get transaction data
  const transactionData = await provider.getTransaction('0x930c973b3ef52649d457d6dcdec62ed9697d483a49bde2845d2e82c3fc94f953')
  const callData = await parseTransaction(transactionData)

  // Estimate Gas
  const gasLimit = await mittenLink.estimateGas.linkWallets(
    ...callData,
    { value: mintPrice }
  )

  // Call function
  const tx = await mittenLink.linkWallets(
    ...callData,
    { gasLimit }
  )
  await tx.wait()

  // Get Wallet Links
  const result = await mittenLink.getWalletLinks(callData.hotWallet)
  console.log(result)

})()