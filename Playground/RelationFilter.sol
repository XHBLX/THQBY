pragma solidity ^0.4.25;

contract RelationFilter {

	struct TreeNode {
		string     _contract;
		bool       _checkOK;
		TreeNode[] _rel;
	}

	mapping(TreeNode => bool) map;

	function add(string _childContract, string _parentContract) public {
		
	}
}