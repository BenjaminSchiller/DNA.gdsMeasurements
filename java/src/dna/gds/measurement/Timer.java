package dna.gds.measurement;

public class Timer {
	protected static long start;

	public static void start() {
		start = System.nanoTime();
	}

	public static long end() {
		return (System.nanoTime() - start);
	}
}
