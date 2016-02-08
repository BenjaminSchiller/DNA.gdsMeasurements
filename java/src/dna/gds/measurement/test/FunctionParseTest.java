package dna.gds.measurement.test;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

public class FunctionParseTest {

	public static void main(String[] args) throws ScriptException {
		int x = 9;
		eval("10.7052 + 28.8563 * log(x)", x);
		eval("66.775 + 0.111471 * x + 0.0127864 * x**2", x);
		eval("44.8208 + 1.4029 * x", x);
		eval("x**2", x);
		eval("log(x)", 3);
	}

	public static void eval(String expr, int x) throws ScriptException {
		expr = expr.replace("**2", "*x");
		expr = expr.replace("**3", "*x*x");
		expr = expr.replace("**4", "*x*x*x");
		expr = expr.replace("**5", "*x*x*x*x");
		expr = expr.replace("**6", "*x*x*x*x*x");
		if (expr.contains("log(x)")) {
			expr = expr.replace("log(x)", Double.toString(Math.log(x)));
		}
		ScriptEngineManager manager = new ScriptEngineManager();
		ScriptEngine engine = manager.getEngineByName("js");
		System.out.println(engine.eval("x=" + x + "; " + expr));
	}
}
