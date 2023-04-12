# Blockchain DAPP

Simple blockchain dapp \
Using Solidity, Truffle, Ganache and Web3 \

## Installation

npm install -g truffle
npm install -g ganache-cli
pip install web3

## Usage

### Start Ganache

    $ganache-cli

### Compile and migrate contracts

    $truffle compile
    $truffle migrate

At this point, copy the contract address from the output of the `truffle migrate` command and paste it into the `client.py` file.

### Run client

    python client.py



