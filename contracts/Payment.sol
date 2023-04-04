// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Payment {

  /* Function registerUser()
  @param user_id: user id
  @param user_name: user name
  Register user and add to list of available users to transact
  */
  struct User {
    string name;
    bool exists;
  }

  mapping(uint256 => User) public users;
  uint256[] public userIDs;

  function registerUser(uint256 user_id, string memory user_name) public {
    users[user_id] = User(user_name, true);
    userIDs.push(user_id);
  }

  /* Function createAcc()
  @param user_id_1: user id of first user
  @param user_id_2: user id of second user
  Create a joint account between two users and keep track of individual contributions
  */
  struct Account {
    uint256 user_id_1;
    uint256 user_id_2;
    uint256 balance_1;
    uint256 balance_2;
  }

  //mapping from pair of user ids to account, and adjacency list
  mapping(uint256 => mapping(uint256 => Account)) public accounts;
  mapping(uint256 => uint256[]) public adjList;

  function createAcc(uint256 user_id_1, uint256 user_id_2, uint amount) public {
    // Create a new account and add to the mapping and account IDs list
    accounts[user_id_1][user_id_2] = Account(user_id_1, user_id_2, amount/2, amount/2);
    // Add the two users to each other's adjacency list
    adjList[user_id_1].push(user_id_2);
    adjList[user_id_2].push(user_id_1);
  }

  // Depth-first search starting from a given node
  function dfs(uint256 start, uint256 end) public view returns (uint256[] memory) {
      bool[] memory visited = new bool[](userIDs.length);
      uint256[] memory path = new uint256[](userIDs.length);
      uint256 pathIndex = 0;
      bool pathFound = dfsHelper(start, end, visited, path, pathIndex);
      if (pathFound) {
          uint256[] memory result = new uint256[](pathIndex);
          for (uint256 i = 0; i < pathIndex; i++) {
              result[i] = path[i];
          }
          return result;
      } else {
          return new uint256[](0);
      }
  }

  // Recursive helper function for DFS
  function dfsHelper(uint256 node, uint256 end, bool[] memory visited, uint256[] memory path, uint256 pathIndex) private view returns (bool) {
      visited[node] = true;
      path[pathIndex] = node;
      pathIndex++;
      if (node == end) {
          return true;
      }
      for (uint256 i = 0; i < adjList[node].length; i++) {
          uint256 neighbor = adjList[node][i];
          if (!visited[neighbor]) {
              bool pathFound = dfsHelper(neighbor, end, visited, path, pathIndex);
              if (pathFound) {
                  return true;
              }
          }
      }
      return false;
  }

  /* Function sendAmount()
  @param user_id_1: user id of sender
  @param user_id_2: user id of receiver
  Transfer the amount from sender to receiver
  Default amount is 1
  If user doesn’t have sufficient balance, reject transaction
  Check balance of all users on path before transferring amount
  Use DFS to find the shortest path between the two users
  */

  function sendAmount(uint256 user_id_1, uint256 user_id_2, uint amount) public {
    // Find the shortest path between the two users
    uint256[] memory path = dfs(user_id_1, user_id_2);
    // Check if the path exists
    require(path.length != 0, "No path exists");
    // Check if the users on the path have sufficient balance
    for (uint256 i = 0; i < path.length - 1; i++) {
      require(accounts[path[i]][path[i + 1]].balance_1 >= amount, "Insufficient balance");
    }
    // Transfer the amount from sender to receiver via the path
    for (uint256 i = 0; i < path.length - 1; i++) {
      accounts[path[i]][path[i + 1]].balance_1 -= amount;
      accounts[path[i]][path[i + 1]].balance_2 += amount;
    }
  }

  /* Function closeAcc()
  @param user_id_1: user id of first user
  @param user_id_2: user id of second user
  Close the joint account between two users
  */

  function closeAcc(uint256 user_id_1, uint256 user_id_2) public {
    // Remove the two users from each other's adjacency list
    for (uint256 i = 0; i < adjList[user_id_1].length; i++) {
      if (adjList[user_id_1][i] == user_id_2) {
        adjList[user_id_1][i] = adjList[user_id_1][adjList[user_id_1].length - 1];
        adjList[user_id_1].pop();
        break;
      }
    }
    for (uint256 i = 0; i < adjList[user_id_2].length; i++) {
      if (adjList[user_id_2][i] == user_id_1) {
        adjList[user_id_2][i] = adjList[user_id_2][adjList[user_id_2].length - 1];
        adjList[user_id_2].pop();
        break;
      }
    }
    // Remove the account from the mapping
    delete accounts[user_id_1][user_id_2];
  }
}

