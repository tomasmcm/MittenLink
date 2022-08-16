// Right click on the script name and hit 'Run' to execute

const { expect } = require('chai')

describe('MittenLink', function () {
  it('linkWallets', async function () {
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'contracts/artifacts/MittenLink.json'))
    // the variable web3Provider is a remix global variable object
    const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
    let factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);
    let contract = await factory.deploy();
    await contract.deployed()
    console.log('   contract deployed: ' + contract.address + ' (' + contract.deployTransaction.hash + ')')
    
    const coldWallet = '0x890EaCEB4eE2e893f9155Ddf45887885Ba7963f5'
    const hotWallet = '0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567'
    await contract.linkWallets(
      coldWallet,
      hotWallet,
      '0x02ed0403848da68320848da6833a825208942e5deb91b444efbea95e34bfb9aa043a5f99f5678656156ba0c40080c0',
      27,
      '0x45fef98df3f09150c788ad8ac6cf04ade04c6666d45fc77617d9cf68e5808f33',
      '0x0e75977861e736be01d0af5a7c8d518250bfbed7176c6a7848b6435b7f4902ad'
    )

    const result = await contract.getWalletLinks(hotWallet)
    console.log('   getWalletLinks: ' + result)
    expect(result.length).to.equal(1)
    expect(result[0]).to.equal(coldWallet)
  })
})
