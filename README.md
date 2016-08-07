bktree (Haxe Library)
=====================

A basic BK tree implementation in Haxe, based on the C# version from [https://nullwords.wordpress.com/2013/03/13/the-bk-tree-a-data-structure-for-spell-checking/](https://nullwords.wordpress.com/2013/03/13/the-bk-tree-a-data-structure-for-spell-checking/)


Installation
-------

`haxelib install bktree`


Usage
-----

```haxe
class Main {
	static function main() {
		var bk = new BKTree();
		
		for (i in ["boot", "goat", "wolf", "cabbage"]) {
			bk.set(i);
		}
		
		trace(bk.search("toad", 2));
		// > [goat]
		
		trace(bk.search("toad", 3));
		// > [boot, wolf, goat]
		
		trace(BKTree.LevenshteinDistance("toad", "cabbage"));
		// > 6
	}
}
```
