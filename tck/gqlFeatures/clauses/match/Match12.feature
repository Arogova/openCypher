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

Feature: Match12 - Match quantified path patterns
  @new
  Scenario Outline: [1] Fail when path is malformed
    Given an empty graph
    When executing query:
    """
    MATCH <path>
    """
    Then a SyntaxError should be raised at compile time:

    Examples:
      | path |
      | ?    |
      | (n)? |
      | ()?  |
      | *    |
      | ()*  |
      | (n)* |

  @new
  Scenario: [2] Match questioned single edge pattern
    Given an empty graph
    And having executed:
      """
      INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})
      """
    When executing query:
      """
      MATCH (x)-[:KNOWS]->?(y)
      RETURN x.name AS x, y.name AS y
      """
    Then the result should be, in any order:
      | x   | y   |
      | 'A' | 'A' |
      | 'B' | 'B' |
      | 'C' | 'C' |
      | 'A' | 'B' |
      | 'B' | 'C' |
    And no side effects

  @new
  Scenario: [3] Match multiple questioned single edge patterns
    Given an empty graph
    And having executed:
      """
      INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})
      """
    When executing query:
      """
      MATCH (x)-[:KNOWS]->?(y)-[:KNOWS]->?(z)
      RETURN x.name AS x, y.name AS y, z.name AS z
      """
    Then the result should be, in any order:
      | x   | y   | z   |
      | 'A' | 'A' | 'A' |
      | 'B' | 'B' | 'B' |
      | 'C' | 'C' | 'C' |
      | 'A' | 'A' | 'B' |
      | 'A' | 'B' | 'B' |
      | 'B' | 'B' | 'C' |
      | 'B' | 'C' | 'C' |
      | 'A' | 'B' | 'C' |

    And no side effects

  @new
  Scenario: [4] Match questioned two-hop pattern
    Given an empty graph
    And having executed:
      """
      INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})
      """
    When executing query:
      """
      MATCH (x)(-[:KNOWS]->(y)-[:KNOWS]->)?(z)
      RETURN x.name AS x, y.name AS y, z.name AS z
      """
    Then the result should be, in any order:
        | x   | y    | z   |
        | 'A' | null | 'A' |
        | 'B' | null | 'B' |
        | 'C' | null | 'C' |
        | 'A' | 'A'  | 'A' |
        | 'B' | 'B'  | 'B' |
        | 'C' | 'C'  | 'C' |
        | 'A' | 'A'  | 'B' |
        | 'A' | 'B'  | 'B' |
        | 'B' | 'B'  | 'C' |
        | 'B' | 'C'  | 'C' |
        | 'A' | 'B'  | 'C' |

    And no side effects

  @new
  Scenario: [5] Match questioned three-hop pattern
    Given an empty graph
    And having executed:
      """
      INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})-[:KNOWS]->(d:D {name:'D'})
      """
    When executing query:
      """
      MATCH (x)(-[:KNOWS]->(y1)-[:KNOWS]->(y2)-[:KNOWS]->)?(z)
      RETURN x.name AS x, y1.name AS y1, y2.name AS y2, z.name AS z
      """
    Then the result should be, in any order:
      | x   | y1   | y2   | z   |
      | 'A' | null | null | 'A' |
      | 'B' | null | null | 'B' |
      | 'C' | null | null | 'C' |
      | 'D' | null | null | 'D' |
      | 'A' | 'B'  | 'C'  | 'D' |

    And no side effects

  @new
  Scenario: [6] Match quantified then questioned path pattern
    Given an empty graph
    And having executed:
        """
        INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})-[:KNOWS]->(d:D {name:'D'})
        """
    When executing query:
        """
        MATCH (x)-[:KNOWS]->{1,2}(y)-[:KNOWS]->?(z)
        RETURN x.name AS x, y.name AS y, z.name AS z
        """
    Then the result should be, in any order:
      | x   | y   | z   |
      | 'A' | 'B' | 'B' |
      | 'A' | 'B' | 'C' |
      | 'A' | 'C' | 'C' |
      | 'A' | 'C' | 'D' |
      | 'B' | 'C' | 'C' |
      | 'B' | 'C' | 'D' |
      | 'B' | 'D' | 'D' |
      | 'C' | 'D' | 'D' |

    And no side effects

  @new
  Scenario: [7] Match questioned then quantified path pattern
    Given an empty graph
    And having executed:
        """
        INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})-[:KNOWS]->(d:D {name:'D'})
        """
    When executing query:
        """
        MATCH (x)-[:KNOWS]->?(y)-[:KNOWS]->{1,2}(z)
        RETURN x.name AS x, y.name AS y, z.name AS z
        """
    Then the result should be, in any order:
      | x   | y   | z   |
      | 'A' | 'A' | 'B' |
      | 'A' | 'A' | 'C' |
      | 'A' | 'B' | 'C' |
      | 'A' | 'B' | 'D' |
      | 'B' | 'B' | 'C' |
      | 'B' | 'B' | 'D' |
      | 'B' | 'C' | 'D' |
      | 'C' | 'C' | 'D' |
    And no side effects

  @new
  Scenario: [8] Match quantified path in questioned path pattern
    Given an empty graph
    And having executed:
        """
        INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})-[:KNOWS]->(d:D {name:'D'})
        """
    When executing query:
        """
        MATCH (x)(-[:KNOWS]->{1,2}(y)-[:KNOWS]->)?(z)
        RETURN x.name AS x, y.name AS y, z.name AS z
        """
    Then the result should be, in any order:
      | x   | y    | z   |
      | 'A' | null | 'A' |
      | 'B' | null | 'B' |
      | 'C' | null | 'C' |
      | 'D' | null | 'D' |
      | 'A' | 'B'  | 'C' |
      | 'A' | 'C'  | 'D' |
      | 'B' | 'C'  | 'D' |
    And no side effects

  @new
  Scenario: [9] Match questioned path in quantified path pattern
    Given an empty graph
    And having executed:
        """
        INSERT (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})-[:KNOWS]->(d:D {name:'D'})
        """
    When executing query:
        """
        MATCH (x)(-[:KNOWS]->?(y)-[:KNOWS]->){1,2}(z)
        RETURN x.name AS x, y.name AS y, z.name AS z
        """
    Then the result should be, in any order:
      | x   | y         | z   |
      | 'A' | ['A']     | 'B' |
      | 'B' | ['B']     | 'C' |
      | 'C' | ['C']     | 'D' |
      | 'A' | ['B']     | 'C' |
      | 'B' | ['C']     | 'D' |
      | 'A' | ['A','B'] | 'C' |
      | 'B' | ['B','C'] | 'D' |
      | 'A' | ['A','C'] | 'D' |
      | 'A' | ['B','C'] | 'D' |
    And no side effects
