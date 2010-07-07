Feature: Timestamps

  Background:
    Given an empty Person document collection
    And a Person document named 'Fry' :
      | Name          |
      | Philip J. Fry |

  Scenario: Creation time
    When I save the document 'Fry'
    And the document 'Fry' is reloaded
    Then the field created_at of the document 'Fry' is not nil
    And the field updated_at of the document 'Fry' is not nil

