package dna.gds.measurement.test;

import dna.graph.datastructures.DArray;
import dna.graph.datastructures.count.OperationCount.Operation;
import dna.graph.nodes.INode;

public class CostFunctionTest {

	public static void main(String[] args) {
		int[] sizes = new int[] { 100, 10000, 20000, 50000 };
		CostFunction cf = new CostFunction(DArray.class, INode.class,
				Operation.ADD_SUCCESS, sizes);
		System.out.println(cf.eval(1));
		System.out.println(cf.eval(10));
		System.out.println(cf.eval(20));
		System.out.println(cf.eval(100));
		System.out.println(cf.eval(101));
		System.out.println(cf.eval(10000));
		System.out.println(cf.eval(20000));
		System.out.println(cf.eval(50000));
		System.out.println(cf.eval(60000));
	}
}
