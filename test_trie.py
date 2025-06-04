"""
Test the Trie data structure
"""

from trie import Trie


def test_trie() -> None:
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


def test_trie_str() -> None:
    """
    Test the string representation of the trie
    """
    trie = Trie()
    assert "hell, I am a trie" in str(trie)
