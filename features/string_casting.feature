Feature: String casting

  Background:
    Given a class Event

  Scenario: Creating a new document
    When I create an Event 'event' with:
      | Name                 | Venue                          | Date       |
      | NoSQL Live           | John Hancock Conference Center | 2010-03-11 |
    Then the object 'event' has an attribute 'date' of type Date
