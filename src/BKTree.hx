/*
The MIT License (MIT)
Copyright (c) 2013
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package;

/**
 * A basic BK tree implementation in haxe
 * Based on the C# version from https://nullwords.wordpress.com/2013/03/13/the-bk-tree-a-data-structure-for-spell-checking/
 * 
 * Notes:
 *   Words are not stored in lower case as in the C# version (basically because I needed a version preserving cases),
 *   instead toLowerCase is called inside the LevenshteinDistance function.
 *   This might slightly affect performance; for my test data it didn't had much of an impact.
 * 
 * @author Bioruebe
 */
class BKTree {
    private var root:TreeNode;
	
	/**
	 * Instanciate a new and empty BK tree
	 */
	public function new() {}
 
	/**
	 * Adds a new string to the tree
	 * @param	value	The string to add
	 */ 
    public function set(string:String) {
        if (root == null) {
            root = new TreeNode(string);
            return;
        }
 
        var curTreeNode = root;
 
        var dist = LevenshteinDistance(curTreeNode.value, string);
        while (curTreeNode.ContainsKey(dist)) {
            if (dist == 0) return;
 
            curTreeNode = curTreeNode.get(dist);
            dist = LevenshteinDistance(curTreeNode.value, string);
        }
 
        curTreeNode.AddChild(dist, string);
    }
 
	/**
	 * Searches for matches to the given string with a maximum tolerance of d
	 * @param	word	The string to find matches for
	 * @param	d		The maximum tolerance
	 */
    public function search(word:String, d:Int) {
        var rtn = new Array<String>();
        
        recursiveSearch(root, rtn, word, d);
 
        return rtn;
    }
 
    private function recursiveSearch(node:TreeNode, rtn:Array<String>, word:String, d:Int) {
        var curDist = LevenshteinDistance(node.value, word);
        var minDist = curDist - d;
        var maxDist = curDist + d;
 
        if (curDist <= d) rtn.push(node.value);
 
		var a = [for (k in node.keys()) if (minDist <= k && k <= maxDist) k];
		
        for (key in a) {
            recursiveSearch(node.get(key), rtn, word, d);
        }
    }
	
	/**
	 * Calculates the Levenshtein distance between two strings
	 * @param	s1	The first string
	 * @param	s2	The second string
	 */
	public static function LevenshteinDistance(s1:String, s2:String) {
		s1 = s1.toLowerCase();
		s2 = s2.toLowerCase();
		
		var l1 = s1.length;
		var l2 = s2.length;
		var matrix = new Array();
		var line:Array<Int>;
		var i:Int;
		var j:Int;
		
		for (i in 0...l1 + 1) {
			line = new Array();
			for (j in 0...l2 + 1) {
				line.push(i != 0? 0: j);
			}
			line[0] = i;
			matrix.push(line);
		}
		
		var cost:Int; 
		for (i in 1...l1 + 1) {
			for (j in 1...l2 + 1) {
				cost = (s1.charAt(i - 1) == s2.charAt(j - 1))? 0: 1;
				matrix[i][j]=Std.int(Math.min(Math.min(matrix[i-1][j]+1, matrix[i][j-1]+1), matrix[i-1][j-1]+cost));
			}
		}
		return matrix[l1][l2]; 
    }
}
 
private class TreeNode {
    public var value:String;
    public var childNodes:Map<Int, TreeNode>;
 
    public function new(?word:String) {
        value = word;
    }
 
    public function get(key:Int) {
        return childNodes.get(key);
    }
	
	public function keys() {
		if(childNodes == null) return [].iterator();
        return childNodes.keys();
	}
 
    public function ContainsKey(key:Int) {
        return childNodes != null && childNodes.exists(key);
    }
 
    public function AddChild(key:Int, word:String) {
        if(childNodes == null) childNodes = new Map<Int, TreeNode>();
        childNodes.set(key, new TreeNode(word));
    }
	
	public function toString() {
		return value + (childNodes == null? "": childNodes.toString());
	}
}