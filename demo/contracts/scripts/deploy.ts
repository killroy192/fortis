import { ethers, upgrades } from "hardhat";

async function main() {
    const [signer] = await ethers.getSigners();
    const router = "0xab7664500b19a7a2362Ab26081e6DfB971B6F1B0";
    const oracle = '0xab7664500b19a7a2362Ab26081e6DfB971B6F1B0'

    const Consumer = await ethers.getContractFactory("DataStreamsConsumer");
    const consumer = await upgrades.deployProxy(
        Consumer,
        [router, oracle],
        { initializer: "initializer" }
    );
    await consumer.waitForDeployment();

    console.log("Consumer:");
    console.log(await consumer.getAddress());

    await signer.sendTransaction({
        value: ethers.parseEther("0.001"),
        to: await consumer.getAddress(),
    });

    console.log(`sent 0.001 ethers to consumer`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
