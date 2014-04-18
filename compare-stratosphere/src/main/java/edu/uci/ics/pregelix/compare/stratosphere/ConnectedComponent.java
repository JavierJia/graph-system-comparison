package edu.uci.ics.pregelix.compare.stratosphere;

import java.util.Iterator;

import eu.stratosphere.api.common.Plan;
import eu.stratosphere.api.common.Program;
import eu.stratosphere.api.common.ProgramDescription;
import eu.stratosphere.api.common.operators.FileDataSink;
import eu.stratosphere.api.common.operators.FileDataSource;
import eu.stratosphere.api.java.record.io.CsvOutputFormat;
import eu.stratosphere.spargel.java.MessagingFunction;
import eu.stratosphere.spargel.java.SpargelIteration;
import eu.stratosphere.spargel.java.VertexUpdateFunction;
import eu.stratosphere.spargel.java.examples.connectedcomponents.DuplicateLongInputFormat;
import eu.stratosphere.types.LongValue;
import eu.stratosphere.types.NullValue;

public class ConnectedComponent implements Program, ProgramDescription {

	// public static void main(String[] args) throws Exception {
	// LocalExecutor.execute(new SpargelConnectedComponents(), args);
	// }

	@Override
	public Plan getPlan(String... args) {
		final int dop = args.length > 0 ? Integer.parseInt(args[0]) : 1;
		final String inputPath = args.length > 1 ? args[1] : "";
		final String resultPath = args.length > 3 ? args[3] : "";
		final int maxIterations = args.length > 4 ? Integer.parseInt(args[4])
				: Integer.MAX_VALUE;

		FileDataSource initialVertices = new FileDataSource(
				DuplicateLongInputFormat.class, inputPath, "Vertices");
//		FileDataSource edges = new FileDataSource(new CsvInputFormat(' ',
//				LongValue.class, LongValue.class), edgesPath, "Edges");

		// create DataSinkContract for writing the new cluster positions
		FileDataSink result = new FileDataSink(CsvOutputFormat.class,
				resultPath, "Result");
		CsvOutputFormat.configureRecordFormat(result).recordDelimiter('\n')
				.fieldDelimiter(' ').field(LongValue.class, 0)
				.field(LongValue.class, 1);

		SpargelIteration iteration = new SpargelIteration(new CCMessager(),
				new CCUpdater(), "Connected Components (Spargel API)");
		iteration.setVertexInput(initialVertices);
//		iteration.setEdgesInput(edges);
		iteration.setNumberOfIterations(maxIterations);
		result.setInput(iteration.getOutput());

		Plan p = new Plan(result);
		p.setDefaultParallelism(dop);
		return p;
	}

	public static final class CCUpdater extends
			VertexUpdateFunction<LongValue, LongValue, LongValue> {

		private static final long serialVersionUID = 1L;

		@Override
		public void updateVertex(LongValue vertexKey, LongValue vertexValue,
				Iterator<LongValue> inMessages) {
			long min = Long.MAX_VALUE;
			while (inMessages.hasNext()) {
				long next = inMessages.next().getValue();
				min = Math.min(min, next);
			}
			if (min < vertexValue.getValue()) {
				setNewVertexValue(new LongValue(min));
			}
		}

	}

	public static final class CCMessager extends
			MessagingFunction<LongValue, LongValue, LongValue, NullValue> {

		private static final long serialVersionUID = 1L;

		@Override
		public void sendMessages(LongValue vertexId, LongValue componentId) {
			sendMessageToAllNeighbors(componentId);
		}

	}

	@Override
	public String getDescription() {
		return "<dop> <vertices> <edges> <result> <maxIterations>";
	}
}
