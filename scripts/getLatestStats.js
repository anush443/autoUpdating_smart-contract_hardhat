const { getNamedAccounts, ethers, deployments } = require("hardhat")

const main = async () => {
    const { deployer } = await getNamedAccounts()

    const autoUpdating = await ethers.getContractAt(
        "AutoUpdating",
        "0x7c4F4231691787DAeF03F871F7E180c4023D7926",
        deployer
    )
    const a = await autoUpdating.getOwner()
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
