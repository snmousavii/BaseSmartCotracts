// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseInvoice {

    enum Status {
        Created,
        Paid,
        Cancelled
    }

    struct Invoice {
        uint256 id;
        address creator;
        string invoiceRef;
        uint256 amount;
        uint256 createdAt;
        Status status;
    }

    mapping(address => Invoice[]) public invoices;

    event InvoiceCreated(
        address indexed creator,
        uint256 indexed invoiceId,
        string invoiceRef,
        uint256 amount
    );

    event InvoicePaid(
        address indexed creator,
        uint256 indexed invoiceId
    );

    event InvoiceCancelled(
        address indexed creator,
        uint256 indexed invoiceId
    );

    function createInvoice(
        string calldata invoiceRef,
        uint256 amount
    ) external {
        require(
            bytes(invoiceRef).length > 0,
            "Empty invoice reference"
        );

        require(
            amount > 0,
            "Invalid amount"
        );

        uint256 invoiceId = invoices[msg.sender].length;

        invoices[msg.sender].push(
            Invoice({
                id: invoiceId,
                creator: msg.sender,
                invoiceRef: invoiceRef,
                amount: amount,
                createdAt: block.timestamp,
                status: Status.Created
            })
        );

        emit InvoiceCreated(
            msg.sender,
            invoiceId,
            invoiceRef,
            amount
        );
    }

    function markPaid(
        uint256 invoiceId
    ) external {
        require(
            invoiceId < invoices[msg.sender].length,
            "Invalid invoice"
        );

        require(
            invoices[msg.sender][invoiceId].status == Status.Created,
            "Invoice not active"
        );

        invoices[msg.sender][invoiceId].status = Status.Paid;

        emit InvoicePaid(
            msg.sender,
            invoiceId
        );
    }

    function cancelInvoice(
        uint256 invoiceId
    ) external {
        require(
            invoiceId < invoices[msg.sender].length,
            "Invalid invoice"
        );

        require(
            invoices[msg.sender][invoiceId].status == Status.Created,
            "Invoice not active"
        );

        invoices[msg.sender][invoiceId].status = Status.Cancelled;

        emit InvoiceCancelled(
            msg.sender,
            invoiceId
        );
    }

    function getInvoiceCount(
        address user
    ) external view returns (uint256) {
        return invoices[user].length;
    }

    function getInvoice(
        address user,
        uint256 invoiceId
    )
        external
        view
        returns (
            uint256 id,
            address creator,
            string memory invoiceRef,
            uint256 amount,
            uint256 createdAt,
            Status status
        )
    {
        require(
            invoiceId < invoices[user].length,
            "Invalid invoice"
        );

        Invoice memory invoice = invoices[user][invoiceId];

        return (
            invoice.id,
            invoice.creator,
            invoice.invoiceRef,
            invoice.amount,
            invoice.createdAt,
            invoice.status
        );
    }
}
