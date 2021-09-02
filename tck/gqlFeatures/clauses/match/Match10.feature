#
# Copyright (c) 2015-2021 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Attribution Notice under the terms of the Apache License 2.0
#
# This work was created by the collective efforts of the openCypher community.
# Without limiting the terms of Section 6, any Derivative Work that is not
# approved by the public consensus process of the openCypher Implementers Group
# should not be described as “Cypher” (and Cypher® is a registered trademark of
# Neo4j Inc.) or as "openCypher". Extensions by implementers or prototypes or
# proposals for change that have been documented or implemented should only be
# described as "implementation extensions to Cypher" or as "proposed changes to
# Cypher that are not yet approved by the openCypher community".
#

#encoding: utf-8

Feature: Match10 - Match label expressions

  @new
  Scenario Outline: [1] Fail when label contains negation or disjunction in INSERT query
    Given an empty graph
    When executing query:
      """
      INSERT (:<label>)
      """
    Then a SyntaxError should be raised at compile time: UnexpectedSyntax #Needs a more precise error

    Examples:
      | label |
      | !A    |
      | A\|B  |

  @new
  Scenario Outline: [2] Fail when label expression is malformed
    Given an empty graph
    When executing query:
     """
      MATCH (n:<label>)
      RETURN n
      """
    Then a SyntaxError should be raised at compile time: UnexpectedSyntax #Needs a more precise error

    Examples:
      | label |
      | !     |
      | A\|   |
      | A&    |
      | (A&B  |
      | A&&   |
      | A&\|B |
      | A!&B  |

  @new
  Scenario: [3] Match simple conjunctions
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      MATCH (n:A&B)
      RETURN n
      """
    Then the result should be, in any order:
      | n      |
      | (:A&B) |
    And no side effects

  @new
  Scenario: [4] Match simple disjunctions
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      MATCH (n:A|B)
      RETURN n
      """
    Then the result should be, in any order:
      | n       |
      | (:A)    |
      | (:B)    |
      | (:A&B)  |
    And no side effects

  @new
  Scenario: [5] Match simple negations
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      MATCH (n:!A)
      RETURN n
      """
    Then the result should be, in any order:
      | n      |
      | (:B)   |
    And no side effects

  @new
  Scenario: [6] Match negated conjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(A&B))
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A)      |
      | (:B)      |
      | (:C)      |
      | (:A&C)    |
      | (:B&C)    |
    And no side effects

  @new
  Scenario: [7] Match negated disjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(A|B))
      RETURN n
      """
    Then the result should be, in any order:
      | n    |
      | (:C) |
    And no side effects

  @new
  Scenario: [8] Match nested conjunction in disjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:(A&B)|C)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:C)      |
      | (:A&B)    |
      | (:A&C)    |
      | (:B&C)    |
      | (:A&B&C)  |
    And no side effects

  @new
  Scenario: [9] Match nested disjunction in conjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:A&(B|C))
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A&B)    |
      | (:A&C)    |
      | (:A&B&C)  |
    And no side effects

  @new
  Scenario: [10] Match nested negation in conjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:(!A)&B)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:B)      |
      | (:B&C)    |
    And no side effects

  @new
  Scenario: [11] Match nested negation in disjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:(!A)|B)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:B)      |
      | (:C)      |
      | (:A&B)    |
      | (:B&C)    |
      | (:A&B&C)  |
    And no side effects

  @new
  Scenario: [12] Match partly negated disjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(A|B)|C)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:C)      |
      | (:A&C)    |
      | (:B&C)    |
      | (:A&B&C)  |
    And no side effects

  @new
  Scenario: [13] Match partly negated conjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(A&B)&C)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:C)      |
      | (:A&C)    |
      | (:B&C)    |
    And no side effects

  @new
  Scenario: [14] Match negated disjunction in conjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(A|B)&C)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:C)      |
    And no side effects

  @new
  Scenario: [15] Match negated conjunction in disjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(A&B)|C)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A)      |
      | (:B)      |
      | (:C)      |
      | (:A&C)    |
      | (:B&C)    |
      | (:A&B&C)  |
    And no side effects

  @new
  Scenario: [16] Match negated partly negated disjunction
    # !(!(A|B)|C) is equivalent to (A|B)&!C
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(!(A|B)|C))
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A)      |
      | (:B)      |
      | (:A&B)    |
    And no side effects

  @new
  Scenario: [17] Match negated partly negated conjunction
    # !(!(A&B)&C) is equivalent to (A&!C)|(B&!C)
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(!(A&B)&C))
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A)      |
      | (:B)      |
      | (:A&B)    |
    And no side effects

  @new
  Scenario: [18] Match negated conjunction with negation disjunction
    # !(!(A|B)&C) is equivalent to A|B|!C
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(!(A|B)&C))
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A)      |
      | (:B)      |
      | (:A&B)    |
      | (:A&C)    |
      | (:B&C)    |
      | (:A&B&C)  |
    And no side effects

  @new
  Scenario: [19] Match negated disjunction with negated conjunction
    #!(!(A&B)|C) is equivalent to A&B&!C
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      MATCH (n:!(!(A&B)|C))
      RETURN n
      """
    Then the result should be, in any order:
      | n      |
      | (:A&B) |
    And no side effects

  @new
  Scenario: [20] Match negated partly negated disjunction in disjunction
    # !(!(A|B)|C)|D is equivalent to (A&B)|!C|D
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A|B)|C)|D)
      RETURN n
      """
    Then the result should be, in any order:
      | n          |
      | (:A)       |
      | (:B)       |
      | (:D)       |
      | (:A&B)     |
      | (:A&D)     |
      | (:B&D)     |
      | (:C&D)     |
      | (:A&B&C)   |
      | (:A&B&D)   |
      | (:A&C&D)   |
      | (:B&C&D)   |
      | (:A&B&C&D) |
    And no side effects

  @new
  Scenario: [21] Match negated partly negated conjunction in disjunction
    # !(!(A&B)&C)|D is equivalent to (A&!C)|(B&!C)|D
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A&B)&C)|D)
      RETURN n
      """
    Then the result should be, in any order:
      | n          |
      | (:A)       |
      | (:B)       |
      | (:D)       |
      | (:A&B)     |
      | (:A&D)     |
      | (:B&D)     |
      | (:C&D)     |
      | (:A&B&D)   |
      | (:A&C&D)   |
      | (:B&C&D)   |
      | (:A&B&C&D) |
    And no side effects

  @new
  Scenario: [22] Match negated conjunction with negation disjunction in disjunction
    # !(!(A|B)&C)|D is equivalent to A|B|!C|D
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A|B)&C)|D)
      RETURN n
      """
    Then the result should be, in any order:
      | n          |
      | (:A)       |
      | (:B)       |
      | (:D)       |
      | (:A&B)     |
      | (:A&C)     |
      | (:A&D)     |
      | (:B&C)     |
      | (:B&D)     |
      | (:C&D)     |
      | (:A&B&C)   |
      | (:A&B&D)   |
      | (:A&C&D)   |
      | (:B&C&D)   |
      | (:A&B&C&D) |
    And no side effects

  @new
  Scenario: [23] Match negated disjunction with negated conjunction in disjunction
    #!(!(A&B)|C)|D is equivalent to (A&B&!C)|D
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A&B)|C)|D)
      RETURN n
      """
    Then the result should be, in any order:
      | n          |
      | (:D)       |
      | (:A&B)     |
      | (:A&D)     |
      | (:B&D)     |
      | (:C&D)     |
      | (:A&B&D)   |
      | (:A&C&D)   |
      | (:B&C&D)   |
      | (:A&B&C&D) |
    And no side effects

  @new
  Scenario: [24] Match negated partly negated disjunction in conjunction
    # !(!(A|B)|C)&D is equivalent to (A&!C&D)|(B&!C&D)
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A|B)|C)&D)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A&D)    |
      | (:B&D)    |
      | (:A&B&D)  |
    And no side effects

  @new
  Scenario: [25] Match negated partly negated conjunction in conjunction
    # !(!(A&B)&C)&D is equivalent to (A&B&D)|(!C&D)
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A&B)&C)&D)
      RETURN n
      """
    Then the result should be, in any order:
      | n          |
      | (:D)       |
      | (:A&D)     |
      | (:B&D)     |
      | (:A&B&D)   |
      | (:A&B&C&D) |
    And no side effects

  @new
  Scenario: [26] Match negated conjunction with negation disjunction in conjunction
    # !(!(A|B)&C)&D is equivalent to (A&D)|(B&D)|(!C&D)
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A|B)&C)&D)
      RETURN n
      """
    Then the result should be, in any order:
      | n          |
      | (:D)       |
      | (:A&D)     |
      | (:B&D)     |
      | (:A&B&D)   |
      | (:A&C&D)   |
      | (:B&C&D)   |
      | (:A&B&C&D) |
    And no side effects

  @new
  Scenario: [27] Match negated disjunction with negated conjunction in conjunction
    #!(!(A&B)|C)&D is equivalent to A&B&!C&D
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:D)
      INSERT (:A&B), (:A&C), (:A&D), (:B&C), (:B&D), (:C&D)
      INSERT (:A&B&C), (:A&B&D), (:A&C&D), (:B&C&D), (:A&B&C&D)
      """
    When executing query:
      """
      MATCH (n:!(!(A&B)|C)&D)
      RETURN n
      """
    Then the result should be, in any order:
      | n         |
      | (:A&B&D)  |
    And no side effects
