package dna.gds.measurement.test;

import static org.junit.Assert.*;

import org.junit.Test;

import dna.graph.IElement;
import dna.graph.datastructures.DArray;
import dna.graph.datastructures.DHashSet;
import dna.graph.datastructures.GDS;
import dna.graph.datastructures.GraphDataStructure;
import dna.graph.datastructures.IDataStructure;
import dna.graph.datastructures.IEdgeListDatastructureReadable;
import dna.graph.datastructures.INodeListDatastructureReadable;
import dna.graph.datastructures.DataStructure.ListType;
import dna.graph.edges.Edge;
import dna.graph.nodes.Node;
import dna.util.Rand;

public class DSValidation {

	@Test
	public void test() {
		GraphDataStructure gds1 = GDS.undirected(DArray.class);
		GraphDataStructure gds2 = GDS.undirected(DHashSet.class);
		validateV(gds1, gds2);
		validateE(gds1, gds2);
	}

	public static void validateV(GraphDataStructure gds1,
			GraphDataStructure gds2) {
		INodeListDatastructureReadable ds1 = (INodeListDatastructureReadable) gds1
				.newList(ListType.GlobalNodeList);
		INodeListDatastructureReadable ds2 = (INodeListDatastructureReadable) gds2
				.newList(ListType.GlobalNodeList);

		int add = 1000;
		int remove = 20;
		int size = add - 2 * remove;

		for (int i = 0; i < add; i++) {
			Node n = gds1.newNodeInstance(Rand.rand.nextInt(add * 10));
			while (ds1.contains(n) || ds2.contains(n)) {
				n = gds1.newNodeInstance(Rand.rand.nextInt(add * 10));
			}
			assertTrue(ds1.add(n));
			assertTrue(ds2.add(n));
			assertFalse(ds1.add(n));
			assertFalse(ds2.add(n));
		}
		for (int i = 0; i < remove; i++) {
			Node n1 = (Node) ds1.getRandom();
			assertTrue(ds1.remove(n1));
			assertTrue(ds2.remove(n1));
			Node n2 = (Node) ds2.getRandom();
			assertFalse(ds1.remove(n2));
			assertFalse(ds2.remove(n2));
		}

		System.out.println(ds1.getClass().getSimpleName() + " @ " + ds1.size());
		System.out.println(ds2.getClass().getSimpleName() + " @ " + ds2.size());

		checkContains(ds1, ds2);
		checkSize(ds1, size);
		checkSize(ds2, size);
	}

	public static void validateE(GraphDataStructure gds1,
			GraphDataStructure gds2) {
		IEdgeListDatastructureReadable ds1 = (IEdgeListDatastructureReadable) gds1
				.newList(ListType.GlobalEdgeList);
		IEdgeListDatastructureReadable ds2 = (IEdgeListDatastructureReadable) gds2
				.newList(ListType.GlobalEdgeList);

		int add = 1000;
		int remove = 20;
		int size = add - 2 * remove;

		for (int i = 0; i < add; i++) {
			Edge e = gds1.newEdgeInstance(
					gds1.newNodeInstance(Rand.rand.nextInt(add)),
					gds1.newNodeInstance(Rand.rand.nextInt(add)));
			while (ds1.contains(e) || ds2.contains(e)) {
				e = gds1.newEdgeInstance(
						gds1.newNodeInstance(Rand.rand.nextInt(add)),
						gds1.newNodeInstance(Rand.rand.nextInt(add)));
			}
			ds1.add(e);
			ds2.add(e);
			ds1.add(e);
			ds2.add(e);
		}
		for (int i = 0; i < remove; i++) {
			Edge e1 = (Edge) ds1.getRandom();
			ds1.remove(e1);
			ds2.remove(e1);
			ds1.remove(e1);
			ds2.remove(e1);
			Edge e2 = (Edge) ds2.getRandom();
			ds1.remove(e2);
			ds2.remove(e2);
			ds1.remove(e2);
			ds2.remove(e2);
		}

		System.out.println(ds1.getClass().getSimpleName() + " @ " + ds1.size());
		System.out.println(ds2.getClass().getSimpleName() + " @ " + ds2.size());

		checkContains(ds1, ds2);
		checkSize(ds1, size);
		checkSize(ds2, size);
	}

	public static void checkContains(IDataStructure ds1, IDataStructure ds2) {
		for (IElement e : ds1) {
			if (!ds2.contains(e)) {
				System.out.println(ds2.getClass().getSimpleName()
						+ " does not contain e (but contained in "
						+ ds2.getClass().getSimpleName());
			}
		}
	}

	public static void checkSize(IDataStructure ds, int size) {
		if (ds.size() != size) {
			System.out.println(ds.getClass().getSimpleName() + ".size = "
					+ ds.size() + " != " + size);
		}
	}

}
