// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseInventory {

    struct Item {
        string name;
        uint256 quantity;
        uint256 price;
        bool exists;
    }

    mapping(address => mapping(uint256 => Item)) public items;
    mapping(address => uint256) public itemCount;

    event ItemCreated(
        address indexed owner,
        uint256 indexed itemId,
        string name,
        uint256 quantity,
        uint256 price
    );

    event InventoryUpdated(
        address indexed owner,
        uint256 indexed itemId,
        uint256 quantity,
        uint256 price
    );

    function createItem(
        uint256 itemId,
        string calldata name,
        uint256 quantity,
        uint256 price
    ) external {
        require(
            bytes(name).length > 0,
            "Empty name"
        );

        require(
            !items[msg.sender][itemId].exists,
            "Item already exists"
        );

        items[msg.sender][itemId] = Item({
            name: name,
            quantity: quantity,
            price: price,
            exists: true
        });

        itemCount[msg.sender]++;

        emit ItemCreated(
            msg.sender,
            itemId,
            name,
            quantity,
            price
        );
    }

    function updateInventory(
        uint256 itemId,
        uint256 quantity,
        uint256 price
    ) external {
        require(
            items[msg.sender][itemId].exists,
            "Item not found"
        );

        items[msg.sender][itemId].quantity = quantity;
        items[msg.sender][itemId].price = price;

        emit InventoryUpdated(
            msg.sender,
            itemId,
            quantity,
            price
        );
    }

    function removeItem(uint256 itemId) external {
        require(
            items[msg.sender][itemId].exists,
            "Item not found"
        );

        delete items[msg.sender][itemId];
        itemCount[msg.sender]--;
    }

    function getItem(
        address owner,
        uint256 itemId
    )
        external
        view
        returns (
            string memory name,
            uint256 quantity,
            uint256 price,
            bool exists
        )
    {
        Item memory item = items[owner][itemId];

        return (
            item.name,
            item.quantity,
            item.price,
            item.exists
        );
    }
}
