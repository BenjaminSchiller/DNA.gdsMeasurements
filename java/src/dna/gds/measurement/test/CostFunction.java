package dna.gds.measurement.test;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import dna.graph.IElement;
import dna.graph.datastructures.IDataStructure;
import dna.graph.datastructures.count.OperationCount.Operation;
import dna.util.Config;

public class CostFunction {
	public Class<? extends IDataStructure> ds;
	public Class<? extends IElement> dt;
	public Operation o;

	public int[] sizes;
	public String[] functions;

	public static ScriptEngine engine = new ScriptEngineManager()
			.getEngineByName("js");

	public CostFunction(Class<? extends IDataStructure> ds,
			Class<? extends IElement> dt, Operation o, int[] sizes) {
		this.ds = ds;
		this.dt = dt;
		this.o = o;
		this.sizes = sizes;
		this.functions = new String[sizes.length];
		for (int i = 0; i < sizes.length; i++) {
			String key = this.dt.getSimpleName().replaceFirst("I", "") + "_"
					+ this.sizes[i] + "_" + this.ds.getSimpleName() + "_" + o
					+ "_f1";
			this.functions[i] = Config.get(key);
			this.functions[i] = this.functions[i].replace("**2", "*x");
			this.functions[i] = this.functions[i].replace("**3", "*x*x");
			this.functions[i] = this.functions[i].replace("**4", "*x*x*x");
			this.functions[i] = this.functions[i].replace("**5", "*x*x*x*x");
			this.functions[i] = this.functions[i].replace("**6", "*x*x*x*x*x");
		}
	}

	protected String getFunction(int x) {
		for (int i = 0; i < this.sizes.length; i++) {
			if (x <= this.sizes[i]) {
				System.out.println(x + " -> " + i);
				return this.functions[i];
			}
		}
		System.out.println(x + " -> " + (functions.length - 1));
		return this.functions[this.functions.length - 1];
	}

	public double eval(int x) {
		try {
			String expr = this.getFunction(x);
			System.out.println("  " + expr);
			if (expr.contains("log(x)")) {
				expr = expr.replace("log(x)", Double.toString(Math.log(x)));
			}
			expr = "x=" + x + "; " + expr;
			double v = Double.parseDouble(engine.eval(expr).toString());
			return Math.max(0, v);
		} catch (ScriptException e) {
			e.printStackTrace();
			return -1;
		}
	}
}
