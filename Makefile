-include .env

.PHONY: all test clean install compile snapshot 

all: clean install test

# Clean the repo
clean :; forge clean

# Local installation
install :; npm i && npx husky install

# CI installation
install-ci :; touch .env; npm ci

# Update Dependencies
forge-update:; forge update

compile :; npx hardhat compile

test :; forge test -vvv; npx hardhat test

snapshot :; forge snapshot

format :; forge fmt src/; forge fmt test/

lint :; npx solhint src/**/*.sol

node :; npx hardhat node

network?=hardhat

deploy :; npx hardhat --network $(network) deploy-bundle

-include ${FCT_PLUGIN_PATH}/makefile-external
