// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title MetaEdge-Chain
 * @notice A decentralized edge computing coordination contract where nodes register, contribute computing power,
 *         and earn rewards for verified computations.
 */
contract Project {
    address public admin;
    uint256 public totalNodes;
    uint256 public totalTasks;

    struct Node {
        address nodeAddress;
        string metadata;
        uint256 stakedAmount;
        uint256 completedTasks;
        bool registered;
    }

    struct Task {
        uint256 id;
        string description;
        address assignedNode;
        bool completed;
        uint256 reward;
    }

    mapping(address => Node) public nodes;
    mapping(uint256 => Task) public tasks;

    event NodeRegistered(address indexed node, string metadata, uint256 stake);
    event TaskCreated(uint256 indexed id, string description, uint256 reward);
    event TaskAssigned(uint256 indexed id, address indexed node);
    event TaskCompleted(uint256 indexed id, address indexed node, uint256 reward);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyRegisteredNode() {
        require(nodes[msg.sender].registered, "Not a registered node");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Register a new edge node with metadata and stake
     */
    function registerNode(string memory _metadata) external payable {
        require(!nodes[msg.sender].registered, "Node already registered");
        require(msg.value > 0, "Must stake some ETH to register");

        totalNodes++;
        nodes[msg.sender] = Node(msg.sender, _metadata, msg.value, 0, true);

        emit NodeRegistered(msg.sender, _metadata, msg.value);
    }

    /**
     * @notice Admin creates a new computation task
     */
    function createTask(string memory _description, uint256 _reward) external payable onlyAdmin {
        require(msg.value == _reward, "Reward must be funded");

        totalTasks++;
        tasks[totalTasks] = Task(totalTasks, _description, address(0), false, _reward);

        emit TaskCreated(totalTasks, _description, _reward);
    }

    /**
     * @notice Assign a task to a registered node
     */
    function assignTask(uint256 _taskId, address _node) external onlyAdmin {
        require(nodes[_node].registered, "Invalid node");
        Task storage task = tasks[_taskId];
        require(!task.completed, "Task already completed");
        require(task.assignedNode == address(0), "Task already assigned");

        task.assignedNode = _node;

        emit TaskAssigned(_taskId, _node);
    }

    /**
     * @notice Mark task as completed and reward the node
     */
    function completeTask(uint256 _taskId) external onlyRegisteredNode {
        Task storage task = tasks[_taskId];
        require(task.assignedNode == msg.sender, "Not assigned to this node");
        require(!task.completed, "Task already completed");

        task.completed = true;
        nodes[msg.sender].completedTasks++;

        payable(msg.sender).transfer(task.reward);

        emit TaskCompleted(_taskId, msg.sender, task.reward);
    }

    /**
     * @notice View node details
     */
    function getNode(address _node) external view returns (Node memory) {
        return nodes[_node];
    }

    /**
     * @notice View task details
     */
    function getTask(uint256 _taskId) external view returns (Task memory) {
        return tasks[_taskId];
    }
}
// 
End
// 
