"""
Trie is a tree-like data structure that stores a dynamic set of strings.
It is used to store a dynamic set or associative array where the keys are usually strings.
"""

# This is a trie data structure implementation in Python


# pylint: disable=too-few-public-methods
class TrieNode:
    """
    TrieNode is a node in the trie data structure.
    It contains a dictionary of children nodes and a boolean
    flag to indicate if the node is the end of a word.
    """

    def __init__(self) -> None:
        self.children: dict[str, "TrieNode"] = {}
        self.is_end_of_word: bool = False


class Trie:
    """
    Trie is a tree-like data structure that stores a dynamic set of strings.
    It is used to store a dynamic set or associative array where the keys are usually strings.
    """

    def __init__(self) -> None:
        self.root = TrieNode()

    def __str__(self) -> str:
        """
        Return a string representation of the trie
        """
        return "hell, I am a trie"

    def insert(self, word: str) -> None:
        """
        Insert a word into the trie
        """
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end_of_word = True

    def search(self, word: str) -> bool:
        """
        Search for a word in the trie
        """
        node = self.root
        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]
        return node.is_end_of_word

    def starts_with(self, prefix: str) -> bool:
        """
        Check if the trie starts with a given prefix
        """
        node = self.root
        for char in prefix:
            if char not in node.children:
                return False
            node = node.children[char]
        return True
