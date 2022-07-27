const { getNamedAccounts, ethers, deployments } = require("hardhat")

const main = async () => {
    const { deployer } = await getNamedAccounts()

    const autoUpdating = await ethers.getContractAt(
        "AutoUpdating",
        "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
        deployer
    )
    //const a = await autoUpdating.getLatestStats()
    // console.log(
    //     `Temperature : ${temperature.toString()}       Humidity :${humidity.toString()}       Moisture :${moisture.toString()}`
    // )

    console.log(a)
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.log(err)
        process.exit(1)
    })
