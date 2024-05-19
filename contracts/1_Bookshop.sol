// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract Bookshop {
    address public bookshopOwner;
    uint256 public subscriptionFee;
    uint256 public noOfBooks;
    mapping(address => bool) hasSubscribed;
    mapping(uint256 => Book) public books;

    struct Book {
        uint256 id;
        string title;
        bool premium;
    }

    event BookAdded(Book book);
    event SubscriptionPurchase(address indexed subscriber);

    modifier onlyOwner() {
        require(msg.sender == bookshopOwner);
        _;
    }

    constructor(uint256 _subscriptionFee) {
        bookshopOwner = msg.sender;
        subscriptionFee = _subscriptionFee;
    }

    function subscribe() external payable {
        require(msg.sender != bookshopOwner, "You are the bookshop owner.");
        require(
            !hasSubscribed[msg.sender],
            "This account has already subscribed."
        );
        require(msg.value == subscriptionFee, "Incorrect subscription fee.");

        hasSubscribed[msg.sender] = true;
        emit SubscriptionPurchase(msg.sender);
    }

    function addBook(string memory _title, bool _premium) external onlyOwner {
        Book storage book = books[noOfBooks + 1]; // So the books are not zero indexed
        book.id = noOfBooks + 1;
        book.title = _title;
        book.premium = _premium;

        emit BookAdded(book);
        noOfBooks++;
    }

    function accessBook(uint256 _bookId) external view returns (bool) {
        require(_bookId <= noOfBooks, "This book does not exist.");
        if (
            books[_bookId].premium &&
            !hasSubscribed[msg.sender] &&
            msg.sender != bookshopOwner
        ) {
            // If book is premium, account is not the bookshop owner and has not subscribed
            return false;
        }
        return true;
    }

    function withdraw() external onlyOwner {
        payable(bookshopOwner).transfer(address(this).balance);
    }
}
