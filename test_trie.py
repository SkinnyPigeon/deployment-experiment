"""
Test the Trie data structure
"""

from trie import Trie


def test_trie():
    """
    Test the Trie data structure
    """
    trie = Trie()
    trie.insert("apple")
    trie.insert("app")
    assert trie.search("apple") is True
    assert trie.search("app") is True
    assert trie.search("ap") is False
    assert trie.starts_with("app") is True
    assert trie.starts_with("ap") is True
    assert trie.starts_with("a") is True
