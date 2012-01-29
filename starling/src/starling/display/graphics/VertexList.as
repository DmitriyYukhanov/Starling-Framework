package starling.display.graphics 
{
	public class VertexList 
	{
		public var vertex:Vector.<Number>;
		public var next:VertexList;
		public var prev:VertexList;
		public var index:int;
		public var head	:VertexList;
		
		public function VertexList() 
		{
			
		}
		
		static public function reverse( vertexList:VertexList ):void
		{
			var node:VertexList = vertexList.head;
			do
			{
				var temp:VertexList = node.next;
				node.next = node.prev;
				node.prev = temp;
				
				node = temp;
			}
			while ( node != vertexList.head )
		}
			
		static public function build( vertices:Vector.<Number>, stride:int ):VertexList
		{
			var head:VertexList;
			
			var numVertices:int = vertices.length / stride;
			var prevNode:VertexList = head;
			for ( var i:int = 0; i < numVertices; i++ )
			{
				var node:VertexList = getNode();
				if ( head == null )
				{
					head = node;
				}
				node.vertex = vertices.slice(i * stride, i * stride + stride);
				node.head = head;
				node.prev = prevNode;
				node.index = i;
				
				if ( prevNode )
				{
					prevNode.next = node;
				}
				
				prevNode = node;
			}
			
			head.prev = node;
			node.next = head;
			
			return head;
		}
		
		static public function dispose( node:VertexList ):void
		{
			while ( node.head )
			{
				releaseNode(node);
				var temp:VertexList = node.next;
				node.next = null;
				node.prev = null;
				node.head = null;
				node.vertex = null;
				
				node = node.next;
			}
		}
		
		private static var nodePool:Vector.<VertexList> = new Vector.<VertexList>();
		static public function getNode():VertexList
		{
			if ( nodePool.length > 0 )
			{
				return nodePool.pop();
			}
			return new VertexList();
		}
		
		static public function releaseNode( node:VertexList ):void
		{
			node.prev = node.next = node.head = null;
			node.vertex = null;
			node.index = -1;
			nodePool.push(node);
		}
	}
}