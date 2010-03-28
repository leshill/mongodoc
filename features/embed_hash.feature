Feature: Embed Hash

  Background:
    Given a class Event

  Scenario: Creating a new document
    Given an Event document named 'event' :
      | Name                 | Venue                          | Date       |
      | NoSQL Live           | John Hancock Conference Center | 2010-03-11 |
    And an Address document named 'address' :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
    And I put the 'address' object on key 'office' of the 'addresses' hash of 'event'
    When I save the document 'event'
    Then the last return value is true
    And the document 'event' roundtrips
