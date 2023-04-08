import json
from web3 import Web3


#connect to the local ethereum blockchain
provider = Web3.HTTPProvider('http://127.0.0.1:8545')
w3 = Web3(provider)
#check if ethereum is connected
print(w3.is_connected())

#replace the address with your contract address (!very important)
deployed_contract_address = '0xdEF3d09F922C82A8c6533986FAC30F7122e95487'

#path of the contract json file. edit it with your contract json file
compiled_contract_path ="build/contracts/Payment.json"
with open(compiled_contract_path) as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']
contract = w3.eth.contract(address = deployed_contract_address, abi = contract_abi)



'''
#Calling a contract function createAcc(uint,uint,uint)
txn_receipt = contract.functions.createAcc(1, 2, 5).transact({'txType':"0x3", 'from':w3.eth.accounts[0], 'gas':2409638})
txn_receipt_json = json.loads(w3.to_json(txn_receipt))
print(txn_receipt_json) # print transaction hash

# print block info that has the transaction)
print(w3.eth.get_transaction(txn_receipt_json)) 

#Call a read only contract function by replacing transact() with call()

'''

#Add your Code here

#Initialise 100 users using contract function registerUser(uint, str)
for i in range(100):
    txn_receipt = contract.functions.registerUser(i, "User"+str(i)).transact({'txType':"0x3", 'from':w3.eth.accounts[0], 'gas':2409638})
    txn_receipt_json = json.loads(w3.to_json(txn_receipt))
    print(txn_receipt_json) # print transaction hash

#Create connected graph of 100 users following power law distribution

import random
import numpy as np

def power_law_graph(n, m):
    if m > n:
        raise ValueError("m must be less than or equal to n")

    # Start with a small connected graph of m nodes
    graph = {i: [] for i in range(m)}
    for i in range(m):
        for j in range(i + 1, m):
            graph[i].append(j)
            graph[j].append(i)

    # Add remaining nodes to the graph using preferential attachment
    node_degrees = [m - 1] * m
    for i in range(m, n):
        graph[i] = []
        total_degree = sum(node_degrees)
        new_edges = []
        while len(new_edges) < m:
            r = random.random() * total_degree
            node = None
            for j, degree in enumerate(node_degrees):
                r -= degree
                if r <= 0:
                    node = j
                    break
            if node is not None and node != i and node not in new_edges:
                new_edges.append(node)
                graph[i].append(node)
                graph[node].append(i)
                node_degrees[node] += 1
                total_degree += 2
        node_degrees.append(m)
    
    # Return list of edges
    edges = []
    for i in range(n):
        for j in graph[i]:
            if i < j:
                edges.append((i, j))
    return edges

#for each edge in the graph, call the contract function createAcc(uint,uint,uint)
edges = power_law_graph(100, 5)

for edge in edges:
    amount = int(np.random.exponential(10))
    txn_receipt = contract.functions.createAcc(edge[0], edge[1], amount).transact({'txType':"0x3", 'from':w3.eth.accounts[0], 'gas':2409638})
    txn_receipt_json = json.loads(w3.to_json(txn_receipt))
    print(txn_receipt_json) # print transaction hash

#Perform 1000 transactions between random users
for i in range(1000):
    fromUser = random.randint(0, 99)
    toUser = random.randint(0, 99)
    txn_receipt = contract.functions.sendAmount(fromUser, toUser).transact({'txType':"0x3", 'from':w3.eth.accounts[0], 'gas':2409638})
    txn_receipt_json = json.loads(w3.to_json(txn_receipt))
    print(txn_receipt_json) # print transaction hash

#Close all accounts
for i in range(100):
    txn_receipt = contract.functions.closeAcc(i).transact({'txType':"0x3", 'from':w3.eth.accounts[0], 'gas':2409638})
    txn_receipt_json = json.loads(w3.to_json(txn_receipt))
    print(txn_receipt_json) # print transaction hash