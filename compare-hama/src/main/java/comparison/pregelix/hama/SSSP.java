package comparison.pregelix.hama;

import java.io.IOException;
import java.util.Iterator;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.VLongWritable;
import org.apache.hama.HamaConfiguration;
import org.apache.hama.bsp.Combiner;
import org.apache.hama.bsp.HashPartitioner;
import org.apache.hama.bsp.TextInputFormat;
import org.apache.hama.bsp.TextOutputFormat;
import org.apache.hama.graph.Edge;
import org.apache.hama.graph.GraphJob;
import org.apache.hama.graph.Vertex;
import org.apache.hama.graph.VertexInputReader;

public class SSSP {
	public static final String START_VERTEX = "shortest.paths.start.vertex.name";

	public static class ShortestPathVertex extends
			Vertex<VLongWritable, IntWritable, IntWritable> {

		@Override
		public void setup(HamaConfiguration conf) {
			this.setValue(new IntWritable(Integer.MAX_VALUE));
		}

		public boolean isStartVertex() {
			VLongWritable startVertex = new VLongWritable(
					Long.parseLong(getConf().get(START_VERTEX)));
			return (this.getVertexID().equals(startVertex)) ? true : false;
		}

		@Override
		public void compute(Iterable<IntWritable> messages) throws IOException {
			int minDist = isStartVertex() ? 0 : Integer.MAX_VALUE;

			for (IntWritable msg : messages) {
				if (msg.get() < minDist) {
					minDist = msg.get();
				}
			}

			if (minDist < this.getValue().get()) {
				this.setValue(new IntWritable(minDist));
				for (Edge<VLongWritable, IntWritable> e : this.getEdges()) {
					sendMessage(e,
							new IntWritable(minDist + e.getValue().get()));
				}
			}
			voteToHalt();
		}
	}

	public static class MinIntCombiner extends Combiner<IntWritable> {

		@Override
		public IntWritable combine(Iterable<IntWritable> messages) {
			int minDist = Integer.MAX_VALUE;

			Iterator<IntWritable> it = messages.iterator();
			while (it.hasNext()) {
				int msgValue = it.next().get();
				if (minDist > msgValue)
					minDist = msgValue;
			}

			return new IntWritable(minDist);
		}
	}

	public static class SSSPTextReader
			extends
			VertexInputReader<LongWritable, Text, VLongWritable, IntWritable, IntWritable> {

		@Override
		public boolean parseVertex(LongWritable key, Text value,
				Vertex<VLongWritable, IntWritable, IntWritable> vertex)
				throws Exception {

			String line = value.toString();
			String[] nodes = line.split("\\s+");

			// All weight set to 1
			vertex.setVertexID(new VLongWritable(Long.parseLong(nodes[0])));
			for (int i = 2; i < nodes.length; ++i) {
				vertex.addEdge(new Edge<VLongWritable, IntWritable>(
						new VLongWritable(Long.parseLong(nodes[i])),
						new IntWritable(1)));
			}
			return true;
		}

	}

	private static void printUsage() {
		System.out.println("Usage: <input> <output> [tasks] [startnode]  [max-iterations]");
		System.exit(-1);
	}

	public static void main(String[] args) throws IOException,
			InterruptedException, ClassNotFoundException {
		if (args.length < 3)
			printUsage();

		// Graph job configuration
		HamaConfiguration conf = new HamaConfiguration();
		GraphJob ssspJob = new GraphJob(conf, SSSP.class);
		// Set the job name
		ssspJob.setJobName("Single Source Shortest Path");

		ssspJob.setInputPath(new Path(args[0]));
		ssspJob.setOutputPath(new Path(args[1]));

		if (args.length > 2) {
			ssspJob.setNumBspTask(Integer.parseInt(args[2]));
		}

		if (args.length > 3) {
			conf.set(START_VERTEX, args[3]);
		} else {
			conf.set(START_VERTEX, "0");
		}

		if (args.length > 4) {
			ssspJob.setMaxIteration(Integer.parseInt(args[4]));
		} else {
			// Iterate until all the nodes have been reached.
			ssspJob.setMaxIteration(Integer.MAX_VALUE);
		}

		ssspJob.setVertexClass(ShortestPathVertex.class);
		ssspJob.setCombinerClass(MinIntCombiner.class);
		ssspJob.setInputFormat(TextInputFormat.class);
		ssspJob.setInputKeyClass(LongWritable.class);
		ssspJob.setInputValueClass(Text.class);

		ssspJob.setPartitioner(HashPartitioner.class);
		ssspJob.setOutputFormat(TextOutputFormat.class);
		ssspJob.setVertexInputReaderClass(SSSPTextReader.class);
		ssspJob.setOutputKeyClass(VLongWritable.class);
		ssspJob.setOutputValueClass(IntWritable.class);

		ssspJob.setVertexIDClass(VLongWritable.class);
		ssspJob.setVertexValueClass(IntWritable.class);
		ssspJob.setEdgeValueClass(IntWritable.class);

		long startTime = System.currentTimeMillis();
		if (ssspJob.waitForCompletion(true)) {
			System.out.println("Job Finished in "
					+ (System.currentTimeMillis() - startTime) / 1000.0
					+ " seconds");
		}
	}
}
