package comparison.pregelix.hama;

import java.io.IOException;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.VLongWritable;
import org.apache.hama.HamaConfiguration;
import org.apache.hama.bsp.HashPartitioner;
import org.apache.hama.bsp.TextInputFormat;
import org.apache.hama.bsp.TextOutputFormat;
import org.apache.hama.graph.AverageAggregator;
import org.apache.hama.graph.Edge;
import org.apache.hama.graph.GraphJob;
import org.apache.hama.graph.ListVerticesInfo;
import org.apache.hama.graph.Vertex;
import org.apache.hama.graph.VertexInputReader;
import org.apache.hama.graph.VerticesInfo;

/**
 * Real pagerank with dangling node contribution.
 */
public class PageRank {

	public static class PageRankVertex extends
			Vertex<VLongWritable, NullWritable, DoubleWritable> {

		static double DAMPING_FACTOR = 0.85;

		@Override
		public void setup(HamaConfiguration conf) {
			String val = conf.get("hama.pagerank.alpha");
			if (val != null) {
				DAMPING_FACTOR = Double.parseDouble(val);
			}
		}

		@Override
		public void compute(Iterable<DoubleWritable> messages)
				throws IOException {
			// initialize this vertex to 1 / count of global vertices in this
			// graph
			if (this.getSuperstepCount() == 0) {
				setValue(new DoubleWritable(1.0 / this.getNumVertices()));
			} else if (this.getSuperstepCount() >= 1) {
				double sum = 0;
				for (DoubleWritable msg : messages) {
					sum += msg.get();
				}
				double alpha = (1.0d - DAMPING_FACTOR) / this.getNumVertices();
				setValue(new DoubleWritable(alpha + (sum * DAMPING_FACTOR)));
			}

			// in each superstep we are going to send a new rank to our
			// neighbours
			sendMessageToNeighbors(new DoubleWritable(this.getValue().get()
					/ this.getEdges().size()));
		}
	}

	public static class PageRankTextReader
			extends
			VertexInputReader<LongWritable, Text, VLongWritable, NullWritable, DoubleWritable> {
		@Override
		public boolean parseVertex(LongWritable key, Text value,
				Vertex<VLongWritable, NullWritable, DoubleWritable> vertex)
				throws Exception {
			String line = value.toString();
			String[] nodes = line.split("\\s+");

			vertex.setVertexID(new VLongWritable(Long.parseLong(nodes[0])));
			for (int i = 2; i < nodes.length; ++i) {
				vertex.addEdge(new Edge<VLongWritable, NullWritable>(
						new VLongWritable(Long.parseLong(nodes[i])), null));
			}
			return true;
		}
	}

	public static GraphJob createJob(String[] args, HamaConfiguration conf)
			throws IOException {
		GraphJob pageJob = new GraphJob(conf, PageRank.class);
		pageJob.setJobName("Pagerank");

		pageJob.setVertexClass(PageRankVertex.class);
		pageJob.setInputPath(new Path(args[0]));
		pageJob.setOutputPath(new Path(args[1]));

		// set the defaults
		pageJob.setMaxIteration(10);
		pageJob.set("hama.pagerank.alpha", "0.85");
		// reference vertices to itself, because we don't have a dangling node
		// contribution here
		pageJob.set("hama.graph.self.ref", "true");
		pageJob.set("hama.graph.max.convergence.error", "0.001");

		if (args.length >= 3) {
			pageJob.setNumBspTask(Integer.parseInt(args[2]));
		}
		if (args.length > 3) {
			pageJob.setMaxIteration(Integer.parseInt(args[3]));
		}

		// error
		pageJob.setAggregatorClass(AverageAggregator.class);

		// Vertex reader
		pageJob.setVertexInputReaderClass(PageRankTextReader.class);

		pageJob.setVertexIDClass(VLongWritable.class);
		pageJob.setVertexValueClass(DoubleWritable.class);
		pageJob.setEdgeValueClass(NullWritable.class);

		pageJob.setInputFormat(TextInputFormat.class);

		pageJob.setPartitioner(HashPartitioner.class);
		pageJob.setOutputFormat(TextOutputFormat.class);
		pageJob.setOutputKeyClass(VLongWritable.class);
		pageJob.setOutputValueClass(DoubleWritable.class);
		return pageJob;
	}

	private static void printUsage() {
		System.out.println("Usage: <input> <output> [tasks] [max-iterations]");
		System.exit(-1);
	}

	public static void main(String[] args) throws IOException,
			InterruptedException, ClassNotFoundException {
		if (args.length < 2)
			printUsage();

		HamaConfiguration conf = new HamaConfiguration();
		conf.setClass("hama.graph.vertices.info", ListVerticesInfo.class,
				VerticesInfo.class);
		// setting the out of disk message stuff.
		// conf.setClass("hama.messenger.sender.queue.class", theClass, xface);
		// conf.setClass("hama.messenger.receive.queue.class", theClass, xface);

		GraphJob pageJob = createJob(args, conf);

		long startTime = System.currentTimeMillis();
		if (pageJob.waitForCompletion(true)) {
			System.out.println("Job Finished in "
					+ (System.currentTimeMillis() - startTime) / 1000.0
					+ " seconds");
		}
	}
}
