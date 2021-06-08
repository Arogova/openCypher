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

Feature: Match11 - Check boolean algebra laws for label expressions

  @new
  Scenario: [1] Check double negation
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:!!A)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [2] Check conjunctive identity
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:A&%)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [3] Check disjunctive identity
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:A|!%)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [4] Check conjunctive annihilator
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:!%)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:A&!%)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [5] Check disjunctive annihilator
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:%)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:A|%)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [6] Check conjunctive complement
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:!%)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:A&!A)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [7] Check disjunctive complement
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:%)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:A|!A)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [8] Check De Morgan conjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:!A&!B)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:!(A|B))
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [9] Check De Morgan disjunction
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:A&B)
      """
    When executing query:
      """
      CALL {
          MATCH (p:!A|!B)
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:!(A&B))
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [10] Check conjunctive associativity
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A&(B&C))
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:(A&B)&C)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [11] Check disjunctive associativity
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A|(B|C))
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:(A|B)|C)
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [12] Check distributivity of AND over OR
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A&(B|C))
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:(A&B)|(A&C))
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects

  @new
  Scenario: [13] Check distributivity of OR over AND
    Given an empty graph
    And having executed:
      """
      INSERT (:A), (:B), (:C), (:A&B), (:A&C), (:B&C), (:A&B&C)
      """
    When executing query:
      """
      CALL {
          MATCH (p:A|(B&C))
          WITH p ORDER BY p
          RETURN collect(p) AS first
      }
      CALL {
          MATCH (q:(A|B)&(A|C))
          WITH q ORDER BY q
          RETURN collect(q) AS second
      }
      RETURN first = second AS result
      """
    Then the result should be, in any order:
      | result  |
      | true    |
    And no side effects
