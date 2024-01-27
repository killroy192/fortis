# Sol-starter

Template to bootstrap solidity project

## Features

- Foundry for unit testing
- Hardhat for integration tests & deployment
- hardhat-sol-bundler for declarative and smart deployments
- linters, code formatter, pre-commit and pre-push hooks
- Makefile & Docker dev container for convenient and safe development
- Custom github action and quality gate workflow for fast CI strategy implementation

## Requirements

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
- [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (f016135 2022-07-04T00:15:02.930499Z)`
    -   To get the latest of each, just run `foundryup`
- [Node.js](https://nodejs.org/en)
- Optional. [Docker](https://www.docker.com/)
    - You'll need to run docker if you want to use dev container and safely play with smartcontracts & scripts

## Contributing

Contributions are always welcome! Open a PR or an issue!

Please install the following:

And you probably already have `make` installed... but if not [try looking here.](https://askubuntu.com/questions/161104/how-do-i-install-make)

## Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [hardhat-sol-bundler Documentation](https://github.com/dgma/hardhat-sol-bundler)