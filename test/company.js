const Company = artifacts.require('Company');
const truffleAssert = require('truffle-assertions');

contract('Company', (accounts) => {
  console.log(accounts);
  const [user1, user2, user3] = accounts;

  it('1. Should be able to set the right master', async () => {
    // Get deployed contract
    const company = await Company.deployed();

    // Check if the master address equals to user1
    assert.deepEqual(await company.getMaster(), user1);
  });

  it('2. Only master should be able to add owner', async () => {
    // Get deployed contract
    const company = await Company.deployed();

    await truffleAssert.reverts(company.addOwner(user1, { from: user2 }));
  });

  it('3. Master should be able to add owner', async () => {
    // Get deployed contract
    const company = await Company.deployed();

    // Call addOwner(); { from accounts[0] } is added as default who is master
    const tx = await Company.addOwner(user1);

    truffleAssert.eventEmitted(tx, 'OwnerAddition', (ev) => {
      return ev.owner == user1;
    });

    // Check if getOwners() returns owners with user1 as owner
    assert.deepEqual(await company.getOwners(), [user1]);
  });

  it('4. Should be able to check owner', async () => {
    const company = await Company.deployed();

    await company.addOwner(user1);

    // checkIfOwner() should return true since user1 is in the ownerlist
    assert.equal(await company.checkIfOwner(user1), true);
  });

  it('5. Only master should be able to remove the owners', async () => {
    const company = await Company.deployed();

    await truffleAssert.reverts(company.removeOwner(user1, { from: user2 }));
  });

  it('6. master should be able to remove owners', async () => {
    const company = await Company.deployed();

    const tx = await company.removeOwner(user1);
    // check if OwnerRemoval event is emitted
    truffleAssert.eventEmitted(tx, 'OwnerRemoval', (ev) => {
      return ev.owner == user1;
    });
    // ownerList should be empty
    assert.deepEqual(await company.getOwners(), []);
  });

  it('7. master should be able to send his share to owners', async () => {
    const company = await Company.deployed();
    // add user2 as owner
    await company.addOwner(user2);

    // the initial share is 5000000
    assert.equal(await company.getShare(user2), 5000000);

    // add the share of master to user2
    const tx1 = await company.addShare(user2, 1000);

    // check if Transfer event is getting emitted
    truffleAssert.eventEmitted(tx1, 'Transfer', (ev) => {
      return ev.receiver == user2 && ev.amount == 1000;
    });
    // get the share of user2
    const user2Share = await company.getShare(user2);

    // user2 share should be 5000000 + 1000 : 5001000
    assert.equal(user2Share.toString(), 5001000);
  });

  it('8. should not be able to use addShare() to transfer share to non-admins(normal-users)', async () => {
    const company = await Company.deployed();

    await truffleAssert.reverts(company.addShare(user3, 1000));
  });

  it('9. should be able to use giveShare() to transfer share to anyone', async () => {
    const company = await Company.deployed();

    const tx = await company.giveShare(user3, 1500);
    truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
      return ev.receiver == user3 && ev.amount == 1500;
    });

    assert.equal(await company.getShare(user3), 1500);
  });
});
