# Powershell. Get unique AD groups from a list

This scrips takes a list of Active Directory groups (by their names, one per line) and determins which of them are unique among each other AND recursively finds only those which don't have direct or indirect parent which were already travelled.

Example:
There is a following list as input:
A
B
C

Here is hierarchy of the given group (their direct and inderct children to the bottom):
- A
  - K
    - M
  - L
- B
- C
  - M

A: K, L (A has 2 direct children - K and L)
K: M
M: None (doesn't have subgroups)
L: None
B: None
C: M
M: None

The result will be:
B
M
