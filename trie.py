"""
Trie is a tree-like data structure that stores a dynamic set of strings.
It is used to store a dynamic set or associative array where the keys are usually strings.
"""

# This is a trie data structure implementation in Python

class TrieNode:
    """
    TrieNode is a node in the trie data structure.
    It contains a dictionary of children nodes and a boolean flag to indicate if the node is the end of a word.
    """
    def __init__(self):
        self.children = {}
        self.is_end_of_word = False

class Trie:
    """
    Trie is a tree-like data structure that stores a dynamic set of strings.
    It is used to store a dynamic set or associative array where the keys are usually strings.
    """
    def __init__(self):
        self.root = TrieNode()

    def insert(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end_of_word = True

    def search(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]
        return node.is_end_of_word

    def starts_with(self, prefix):
        node = self.root
        for char in prefix:
            if char not in node.children:
                return False
            node = node.children[char]
        return True
