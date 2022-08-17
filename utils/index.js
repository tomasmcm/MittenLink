const ethers = require("ethers");

export const parseTransaction = async ({
  chainId, data, from, gasLimit, maxFeePerGas, maxPriorityFeePerGas nonce, r, s, to, type, v, value
}) => {
  const coldWallet = from
  const hotWallet = to
  const signature = ethers.utils.joinSignature({ v, r, s });
  const { v, r, s } = ethers.utils.splitSignature(signature);
  
  const transactionProperties = await ethers.utils.resolveProperties({
    chainId, data, gasLimit, maxFeePerGas, maxPriorityFeePerGas nonce, to, type, value
  })
  const rawHash = ethers.utils.serializeTransaction(transactionProperties)
  
  return {
    coldWallet,
    hotWallet,
    rawHash,
    v,
    r,
    s
  }
}
