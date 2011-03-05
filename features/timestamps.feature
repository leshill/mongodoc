Feature: Timestamps

  Background:
    Given an empty Person document collection
    And a Person document named 'Fry' :
      | Name          |
      | Philip J. Fry |

  Scenario: Creation time
    Given I save the document 'Fry'
    When the document 'Fry' is reloaded
    Then the field created_at of the document 'Fry' is not nil
    And the field updated_at of the document 'Fry' is not nil

  Scenario: Updated time
    Given I save the document 'Fry'
    And I wait 2 seconds
    And the document 'Fry' is reloaded
    When I update the 'name' for 'Fry' to 'Philip Jay Fry'
    And the document 'Fry' is reloaded
    Then the created_at timestamp is not equal to the updated_at timestamp for the document 'Fry'
