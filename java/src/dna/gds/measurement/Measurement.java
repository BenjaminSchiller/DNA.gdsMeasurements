package dna.gds.measurement;

import java.lang.reflect.InvocationTargetException;

import argList.ArgList;
import argList.types.atomic.ClassArg;
import argList.types.atomic.EnumArg;
import argList.types.atomic.IntArg;
import dna.graph.IElement;
import dna.graph.datastructures.DataStructure;
import dna.graph.datastructures.DataStructure.ListType;
import dna.graph.datastructures.GDS;
import dna.graph.datastructures.GraphDataStructure;
import dna.graph.datastructures.IDataStructure;
import dna.graph.datastructures.IEdgeListDatastructureReadable;
import dna.graph.datastructures.INodeListDatastructureReadable;
import dna.graph.datastructures.IReadable;
import dna.graph.edges.Edge;
import dna.graph.nodes.Node;
import dna.graph.nodes.UndirectedNode;

public class Measurement {

	public static enum ElementType {
		Node, Edge
	}

	public Class<? extends DataStructure> datastructureType;
	public ElementType elementType;
	public int maxListSize;
	public int parallelLists;
	public int maxListSizeInit;
	public int parallelListsInit;

	public ListType listType;

	public Measurement(Class<? extends DataStructure> datastructureType,
			String elementType, Integer maxListSize, Integer parallelLists,
			Integer maxListSizeInit, Integer parallelListsInit) {
		this.datastructureType = datastructureType;
		this.elementType = ElementType.valueOf(elementType);
		this.maxListSize = maxListSize;
		this.parallelLists = parallelLists;
		this.maxListSizeInit = maxListSizeInit;
		this.parallelListsInit = parallelListsInit;

		if (this.elementType.equals(ElementType.Node)) {
			this.listType = ListType.GlobalNodeList;
		} else {
			this.listType = ListType.GlobalEdgeList;
		}
	}

	public static void main(String[] args) {
		ArgList<Measurement> argList = new ArgList<Measurement>(
				Measurement.class,
				new ClassArg("datastructureType",
						"full class name of the data structrue to measure"),
				new EnumArg("elementType", "type of data stored in the list",
						ElementType.values()),
				new IntArg("maxListSize",
						"size to grow the list to (and measure operation runtimes)"),
				new IntArg("parallelLists",
						"parallel executions (runtime averaged)"),
				new IntArg("maxListSizeInit",
						"(INIT) size to grow the list to (and measure operation runtimes)"),
				new IntArg("parallelListsInit",
						"(INIT) parallel executions (runtime averaged)"));

		// args = new String[] { "dna.graph.datastructures.DArray", "Node",
		// "50",
		// "3", "10", "2" };

		Measurement m = argList.getInstance(args);
		m.execute();
	}

	public void execute() {
		GraphDataStructure gds = GDS.directed(datastructureType);
		this.execute(gds, this.maxListSizeInit, this.parallelListsInit, false);
		this.execute(gds, this.maxListSize, this.parallelLists, true);
	}

	public void execute(GraphDataStructure gds, int maxSize, int parallel,
			boolean print) {
		if (print) {
			printHeader();
		}
		IDataStructure[] dss = new IDataStructure[parallel];
		for (int i = 0; i < dss.length; i++) {
			dss[i] = gds.newList(listType, datastructureType);
		}
		IElement noElement = null;
		if (elementType.equals(ElementType.Node)) {
			noElement = gds.newNodeInstance(maxSize);
		} else {
			Node src = gds.newNodeInstance(maxSize);
			Node dst = gds.newNodeInstance(maxSize + 1);
			noElement = gds.newEdgeInstance(src, dst);
		}
		for (int i = 1; i <= maxSize; i++) {
			IElement element = null;
			if (elementType.equals(ElementType.Node)) {
				element = gds.newNodeInstance(i - 1);
			} else {
				Node src = gds.newNodeInstance(i);
				Node dst = gds.newNodeInstance(i + 1);
				element = gds.newEdgeInstance(src, dst);
			}
			this.addElement(i, dss, gds, element, noElement, print);
		}
	}

	public static final String sep = "	";

	public void printHeader() {
		System.out.println("# " + this.datastructureType.getSimpleName()
				+ " (datastructureType)");
		System.out.println("# " + this.listType + " (listType)");
		System.out.println("# " + this.maxListSize + " (maxListSize)");
		System.out.println("# " + this.parallelLists + "(parallelLists)");
		System.out.println("# " + this.maxListSizeInit + " (maxListSizeInit)");
		System.out.println("# " + this.parallelListsInit
				+ " (parallelListsInit)");
		System.out.println("SIZE" + sep + "INIT" + sep + "ADD_SUCCESS" + sep
				+ "ADD_FAILURE" + sep + "RANDOM_ELEMENT" + sep + "SIZE" + sep
				+ "ITERATE" + sep + "CONTAINS_SUCCESS" + sep
				+ "CONTAINS_FAILURE" + sep + "GET_SUCCESS" + sep
				+ "GET_FAILURE" + sep + "REMOVE_SUCCESS" + sep
				+ "REMOVE_FAILURE");
	}

	protected void addElement(int size, IDataStructure[] dss,
			GraphDataStructure gds, IElement element, IElement noElement,
			boolean print) {

		// INIT
		Timer.start();
		for (IDataStructure ds : dss) {
			try {
				Class<? extends IElement> dt = UndirectedNode.class;
				IDataStructure list = ds.getClass()
						.getConstructor(ListType.class, dt.getClass())
						.newInstance(listType, dt.getClass());
				list.init(dt, size, true);
			} catch (InstantiationException | IllegalAccessException
					| IllegalArgumentException | InvocationTargetException
					| NoSuchMethodException | SecurityException e) {
				e.printStackTrace();
			}
		}
		long t_INIT = Timer.end();

		// ADD_SUCCESS
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.add(element);
		}
		long t_ADD_SUCCESS = Timer.end();

		// ADD_FAILURE
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.add(element);
		}
		long t_ADD_FAILURE = Timer.end();

		// RANDOM_ELEMENT
		Timer.start();
		IElement randomElement = null;
		for (IDataStructure ds : dss) {
			randomElement = ((IReadable) ds).getRandom();
		}
		long t_RANDOM_ELEMENT = Timer.end();

		// SIZE
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.size();
		}
		long t_SIZE = Timer.end();

		// ITERATE
		Timer.start();
		for (IDataStructure ds : dss) {
			for (IElement e : ds) {
			}
		}
		long t_ITERATE = Timer.end();

		// CONTAINS_SUCCESS
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.contains(element);
		}
		long t_CONTAINS_SUCCESS = Timer.end();

		// CONTAINS_FAILURE
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.contains(noElement);
		}
		long t_CONTAINS_FAILURE = Timer.end();

		// GET_SUCCESS
		Timer.start();
		for (IDataStructure ds : dss) {
			if (element instanceof Node) {
				int index = ((Node) element).getIndex();
				((INodeListDatastructureReadable) ds).get(index);
			} else {
				int n1 = ((Edge) element).getN1Index();
				int n2 = ((Edge) element).getN2Index();
				((IEdgeListDatastructureReadable) ds).get(n1, n2);
			}
		}
		long t_GET_SUCCESS = Timer.end();

		// GET_FAILURE
		Timer.start();
		for (IDataStructure ds : dss) {
			if (element instanceof Node) {
				int index = ((Node) noElement).getIndex();
				((INodeListDatastructureReadable) ds).get(index);
			} else {
				int n1 = ((Edge) noElement).getN1Index();
				int n2 = ((Edge) noElement).getN2Index();
				((IEdgeListDatastructureReadable) ds).get(n1, n2);
			}
		}
		long t_GET_FAILURE = Timer.end();

		// REMOVE_SUCCESS
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.remove(randomElement);
		}
		long t_REMOVE_SUCCESS = Timer.end();

		// REMOVE_FAILURE
		Timer.start();
		for (IDataStructure ds : dss) {
			ds.remove(randomElement);
		}
		long t_REMOVE_FAILURE = Timer.end();

		for (IDataStructure ds : dss) {
			ds.add(randomElement);
		}

		if (print) {
			System.out.println(size + sep + ((double) t_INIT / parallelLists)
					+ sep + ((double) t_ADD_SUCCESS / parallelLists) + sep
					+ ((double) t_ADD_FAILURE / parallelLists) + sep
					+ ((double) t_RANDOM_ELEMENT / parallelLists) + sep
					+ ((double) t_SIZE / parallelLists) + sep
					+ ((double) t_ITERATE / parallelLists) + sep
					+ ((double) t_CONTAINS_SUCCESS / parallelLists) + sep
					+ ((double) t_CONTAINS_FAILURE / parallelLists) + sep
					+ ((double) t_GET_SUCCESS / parallelLists) + sep
					+ ((double) t_GET_FAILURE / parallelLists) + sep
					+ ((double) t_REMOVE_SUCCESS / parallelLists) + sep
					+ ((double) t_REMOVE_FAILURE / parallelLists));
		}

	}
}
