Feature: MongoDoc::Base

  Background:
    Given an empty Contact document collection
    And a Contact document named 'hashrocket' :
      | Name       | Type    |
      | Hashrocket | company |
    And 'hashrocket' has interests, an array of:
      | Interest      |
      | ruby          |
      | rails         |
      | employment    |
      | contract work |
      | restaurants   |
      | hotels        |
      | flights       |
      | car rentals   |
    And 'hashrocket' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 320 First Street North | Jacksonville Beach | FL    | 32250    |
      | 1 Lake Michigan Street | Chicago            | IL    | 60611    |
      | 1 Main Street          | Santiago           | Chile |          |
    And I save the document 'hashrocket'
    And a Contact document named 'rocketeer' :
      | Name           |
      | Rocketeer Mike |
    And 'rocketeer' has interests, an array of:
      | Interest    |
      | ruby        |
      | rails       |
      | restaurants |
      | employment  |
    And 'rocketeer' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 1 Main Street          | Atlantic Beach     | FL    | 32233    |
    And I save the document 'rocketeer'
    And a Contact document named 'contractor' :
      | Name          |
      | Contractor Joe |
    And 'contractor' has interests, an array of:
      | Interest      |
      | ruby          |
      | rails         |
      | contract work |
      | flights       |
      | car rentals   |
      | hotels        |
      | restaurants   |
    And 'contractor' has many addresses :
      | Street                 | City               | State | Zip Code |
      | 1 Main St.             | Jacksonville       | FL    | 32218    |
    And I save the document 'contractor'
    And an empty Place document collection
    And a Place document named 'one_ocean' :
      | Name       | Type  |
      | One Ocean  | hotel |
    And 'one_ocean' has one Address as address :
      | Street                 | City               | State | Zip Code |
      | 1 Ocean Street         | Atlantic Beach     | FL    | 32233    |
    And I save the document 'one_ocean'
    And a Place document named 'sea_horse' :
      | Name       | Type  |
      | Sea Horse  | hotel |
    And 'sea_horse' has one Address as address :
      | Street                 | City               | State | Zip Code |
      | 1401 Atlantic Blvd     | Neptune Beach      | FL    | 32266    |
    And I save the document 'sea_horse'
    And a Place document named 'jax' :
      | Name                               | Type    |
      | Jacksonville International Airport | airport |
    And 'jax' has one Address as address :
      | Street                 | City               | State | Zip Code |
      |                        | Jacksonville       | FL    | 32218    |
    And I save the document 'jax'

  Scenario: Counting results
    When I query contacts with criteria all('interests' => ['ruby', 'rails', 'employment'])
    Then the query result has 2 documents

  Scenario: Finding contacts with interests in ruby and rails
    When I query contacts with criteria all('interests' => ['ruby', 'rails', 'employment'])
    Then one of the query results is the document 'rocketeer'

  Scenario: Finding contacts with interests in restaurants or hotels
    When I query contacts with criteria in('interests' => ['restaurants', 'hotels'])
    Then one of the query results is the document 'contractor'

  Scenario: Aggregating Places
    When I query places with criteria only('type').where('address.state' => 'FL').aggregate
    Then the query result with "type" == "hotel" has a count of 2

  Scenario: Excluding places in Neptune Beach
    When I query places with criteria only('type').where('address.city' => 'Neptune Beach').aggregate
    Then the query result with "type" == "hotel" has a count of 1

  Scenario: Using extras to limit results
    When I query contacts with criteria all('interests' => ['ruby', 'rails', 'employment']).limit(1)
    Then the size of the query result is 1

  Scenario: Finding the first result
    When I query contacts with criteria all('interests' => ['ruby', 'rails', 'employment']).first
    Then the query result is equal to the document 'hashrocket'

  Scenario: Grouping places by type
    When I query places with criteria only('type').where('type' => 'hotel').group
    Then the query result with "type" == "hotel" has the document 'one_ocean'

  Scenario: Selecting contacts with in operator
    When I query contacts with criteria in('interests' => ['ruby', 'rails', 'employment'])
    Then the query result has 3 documents

  Scenario: Selecting a contact with the id operator
    When I query contacts with the 'hashrocket' id
    Then the query result has 1 documents
    And the query result is the document 'hashrocket'

  Scenario: Selecting contacts with not in operator
    When I query contacts with criteria not_in('interests' => ['contract work', 'employment'])
    Then the query result has 0 documents

  Scenario: Ordering contacts
    When I query contacts with criteria in('interests' => ['ruby', 'rails']).order_by([[:name, :asc]]).entries
    Then the first query result is the document 'contractor'
    And the last query result is the document 'rocketeer'

  Scenario: Using skip on results
    When I query contacts with criteria all('interests' => ['ruby', 'rails']).skip(1)
    Then the size of the query result is 2
