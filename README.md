# StackPredict Smart Contract

A decentralized prediction market built on the Stacks blockchain that allows users to create markets, place bets, and earn rewards for correct predictions.

## Overview

StackPredict is a smart contract that enables:
- Creation of prediction markets with customizable questions and options
- Betting on market outcomes using STX tokens
- Market resolution by creators
- Claiming winnings for correct predictions

## Features

- **Market Creation**: Anyone can create a prediction market with:
  - Custom questions (up to 100 characters)
  - Multiple options (up to 10 options)
  - Customizable deadlines
  
- **Betting System**:
  - Minimum bet: 10 STX
  - Multiple users can bet on different options
  - Secure STX token transfers
  
- **Market Resolution**:
  - Only market creators can resolve markets
  - Winners can claim double their bet amount
  - Built-in deadline enforcement

## Function Reference

### Public Functions

```clarity
(create-market (question (string-ascii 100)) (options (list 10 (string-ascii 50))) (deadline uint))
```
Creates a new prediction market.

```clarity
(place-bet (market-id uint) (option (string-ascii 50)) (amount uint))
```
Places a bet on a specific market option.

```clarity
(resolve-market (market-id uint) (winning (string-ascii 50)))
```
Resolves a market with the winning option.

```clarity
(claim-winnings (market-id uint))
```
Claims winnings for correct predictions.

### Read-Only Functions

```clarity
(get-market (market-id uint))
```
Returns market details.

```clarity
(get-bet (market-id uint) (user principal))
```
Returns bet details for a specific user.

```clarity
(get-market-count)
```
Returns total number of markets created.

## Error Codes

- `u101`: Deadline passed
- `u102`: Market already resolved
- `u103`: Market not found
- `u104`: Already resolved
- `u105`: Not creator
- `u106`: You lost the bet
- `u107`: No bet found
- `u108`: No winning option
- `u109`: Market not resolved yet
- `u110`: Transfer failed
- `u111`: Amount too low


### Testing
Run the test suite using Clarinet:
```bash
clarinet test
```

