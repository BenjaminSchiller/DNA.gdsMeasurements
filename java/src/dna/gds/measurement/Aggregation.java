package dna.gds.measurement;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;

import argList.ArgList;
import argList.types.atomic.IntArg;
import argList.types.atomic.StringArg;
import dna.util.ArrayUtils;

public class Aggregation {

	public String dir;
	public String suffix;
	public int lines;
	public int index;

	public static final String sep = "	";

	public Aggregation(String dir, String suffix, Integer lines, Integer index) {
		this.dir = dir;
		this.suffix = suffix;
		this.lines = lines;
		this.index = index;
	}

	public static void main(String[] args) throws IOException {
		ArgList<Aggregation> argList = new ArgList<Aggregation>(
				Aggregation.class,
				new StringArg("dir",
						"path to directory where the dat files are located"),
				new StringArg("suffix",
						"suffix of the files in dir to aggregate"),
				new IntArg("lines", "number of lines in the file to aggregate"),
				new IntArg("index",
						"index of the row that should be aggregated (starting with 0)"));

		// args = new String[] {
		// "/Users/benni/TUD/Projects/DNA/DNA.gdsMeasurements/analysis/measurements/Edge/10000/10/DArray/",
		// ".dat", "100", "3" };

		Aggregation aggr = argList.getInstance(args);
		aggr.aggregate();
	}

	public void aggregate() throws IOException {
		String[] files = (new File(this.dir))
				.list(new SuffixFilter(this.suffix));
		double[][] values = new double[this.lines][files.length];
		String name = null;
		for (int j = 0; j < files.length; j++) {
			BufferedReader r = new BufferedReader(
					new FileReader(dir + files[j]));
			String line = null;
			while ((line = r.readLine()) != null) {
				if (!line.startsWith("#")) {
					break;
				}
			}
			name = line.split(sep)[index];
			for (int i = 0; i < this.lines; i++) {
				values[i][j] = Double
						.parseDouble(r.readLine().split(sep)[this.index]);
			}
			r.close();
		}

		System.out.println("# " + name);
		System.out.println("# aggregation of " + files.length + " runs");
		System.out.println("size" + sep + "avg" + sep + "min" + sep + "max"
				+ sep + "med" + sep + "var" + sep + "varLow" + sep + "varUp");
		for (int i = 0; i < values.length; i++) {
			double avg = ArrayUtils.avg(values[i]);
			double min = ArrayUtils.min(values[i]);
			double max = ArrayUtils.max(values[i]);
			double med = ArrayUtils.med(values[i]);
			double var = ArrayUtils.var(values[i]);
			double[] varLowUp = ArrayUtils.varLowUp(values[i], avg);
			System.out.println((i + 1) + sep + avg + sep + min + sep + max
					+ sep + med + sep + var + sep + varLowUp[0] + sep
					+ varLowUp[1]);
		}
	}

	protected static class SuffixFilter implements FilenameFilter {

		public String suffix;

		public SuffixFilter(String suffix) {
			this.suffix = suffix;
		}

		@Override
		public boolean accept(File dir, String name) {
			return name.endsWith(this.suffix);
		}

	}
}
