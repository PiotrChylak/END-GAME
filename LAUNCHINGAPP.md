# Launching the StwoTheEnd Application

This document describes how to launch the application composed of components built with **Dojo** (for the blockchain layer) and **Rust TUI** (text-based user interface). You will need to have the following environments installed beforehand:  
- **Rust**  
- **Dojo CLI tools (`sozo`, `katana`, `torii`)**  - 
- **Starknet CLI (`sncast`)**

https://dojoengine.org/installation

## Step 1: Start the local network

Start a local blockchain using `katana`, which simulates a Starknet environment.

```bash
katana --dev --dev.no-fee --http.cors-origins '*'
```

The `--dev` and `--dev.no-fee` flags enable a development environment with no transaction costs. The `--http.cors-origins '*'` option allows cross-origin requests from tools like a frontend.

## Step 2: Build and migrate the game world

Next, navigate to the `dojo` folder and build/migrate the contracts:

```bash
cd dojo
sozo build
sozo migrate
```

After migration, you'll receive the address of the "World Contract". Save this address — it will be needed later.

Then, inspect the deployed contracts with:

```bash
sozo inspect
```

This command provides addresses of the deployed components, including the `actions contract`. Note this address as well — you’ll use it during token deployment.

## Step 3: Start the `torii` indexer

`torii` listens for events and interactions in the Dojo world. Run it with the World Contract address:

```bash
torii -v <world_contract_address> --http.cors-origins '*'
```

## Step 4: Declare the token contract

Move to the token contract folder and declare the contract class:

```bash
cd stwo_the_end_token
sncast declare --contract-name StwoTheEndToken --fee-token eth
```

After declaration, a `class_hash` will be returned — this represents the version of the contract. Save it for the deployment step.

## Step 5: Deploy the token contract

Using the saved `class_hash` and the previously noted actions contract address, deploy the token contract:

```bash
sncast deploy --class-hash <class_hash> --fee-token eth -c <actions_contract_address> <actions_contract_address>
```

You provide the actions contract address twice as constructor arguments.

## Step 6: Run the user interface

Go to the Rust TUI project folder and run the application:

```bash
cd rust_tui
cargo build
cargo run
```

In the TUI interface:
- Press `t` to toggle between Developer Mode and Story Mode
- Press `q` to quit the application

## Step 7: Initialize the world state

To start the game, execute the following command with the deployed token contract address:

```bash
cd dojo
sozo execute StwoTheEnd-actions start_new_game <token_contract_address>
```

## Step 8: Make in-game decisions

At this point, you can interact with the game world by making decisions. Available options are shown in the TUI. To make a choice:

```bash
sozo execute StwoTheEnd-actions make_decision <decision_ID>
```

Use the appropriate `<decision_ID>` based on the current TUI state.

---

## Summary

The full process includes:
- Setting up the local environment
- Compiling and deploying contracts
- Running the user interface
- Interacting with the game world

This setup allows for safe and cost-free development and testing of the application in a local environment.