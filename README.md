# vault-docs
Guide for using Moon Tropica vesting vault. React front-end in Development.

# Viewing Contract Details

![var](https://user-images.githubusercontent.com/33762147/224403258-c3892167-4079-494c-83ef-9f6d7549719a.png)

# Read Functions

## Contract Length in Days
```
c_t
```
Days 1-1825

## Bend
```
c_i
```
Decimal 4 (1 - 10000)

## Initial Starting Point in %
```
c_y0
```
Decimal 1 (0 - 1000)

# Obtaining Balances

```
getUnlocked_TotalBalance
```
Shows how many tokens are unlocked and locked in the smart contract.

![2023-03-10_12-23-00](https://user-images.githubusercontent.com/33762147/224407854-9e9eae64-baec-48e9-93f8-055798cd496a.png)

# How to Calculate Future Amounts

Clone the following sheet:
https://docs.google.com/spreadsheets/d/1gCMusMnALmzSfq3-xJv59gvbhIfyDmmQAJGaQJZwSSg/edit#gid=0

Replace variables (see green boxes) in the sheet from your contract and replace the green `t` value to the amount of days you want to calculate.

![2023-03-10_12-11-47](https://user-images.githubusercontent.com/33762147/224405788-afb4e781-8e12-4e75-b50a-3f3ebc7527a3.png)

# Visualizing Curve Factor

Replace variables on the left with ones associated in the smart contract.

https://www.desmos.com/calculator/qzbc4usy3z

![2023-03-08_20-14-23](https://user-images.githubusercontent.com/33762147/224409053-1973a585-8b6b-4c05-b950-cf086cc6a68b.png)
