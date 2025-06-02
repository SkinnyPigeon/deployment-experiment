from trie import Trie

def test_trie():
    trie = Trie()
    trie.insert("apple")
    trie.insert("app")
    assert trie.search("apple") == True
    assert trie.search("app") == True
    assert trie.search("ap") == False
    assert trie.starts_with("app") == True
    assert trie.starts_with("ap") == True
    assert trie.starts_with("a") == True