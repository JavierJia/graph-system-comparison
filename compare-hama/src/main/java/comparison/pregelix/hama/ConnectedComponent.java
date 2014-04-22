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
import org.apache.hama.graph.Edge;
import org.apache.hama.graph.GraphJob;
import org.apache.hama.graph.ListVerticesInfo;
import org.apache.hama.graph.Vertex;
import org.apache.hama.graph.VertexInputReader;
import org.apache.hama.graph.VerticesInfo;

public class ConnectedComponent {

	public static class CCVertex extends
			Vertex<VLongWritable, NullWritable, VLongWritable> {

		@Override
		public void compute(Iterable<VLongWritable> messages)
				throws IOException {
			if (this.getSuperstepCount() == 0) {
				long min = this.getVertexID().get();
				for (Edge<VLongWritable, NullWritable> e : this.getEdges()) {
					if (e.getDestinationVertexID().get() < min) {
						min = e.getDestinationVertexID().get();
					}
				}
				setValue(new VLongWritable(min));
				sendMessageToNeighbors(new VLongWritable(min));
			} else {
				long min = this.getValue().get();
				boolean changed = false;
				for (VLongWritable msg : messages) {
					if (msg.get() < min) {
						min = msg.get();
						changed = true;
					}
				}
				if (changed) {
					setValue(new VLongWritable(min));
					sendMessageToNeighbors(new VLongWritable(min));
				}
			}
			voteToHalt();
		}
	}

	public static class CCTextReader
			extends
			VertexInputReader<LongWritable, Text, VLongWritable, NullWritable, VLongWritable> {

		@Override
		public boolean parseVertex(LongWritable key, Text value,
				Vertex<VLongWritable, NullWritable, VLongWritable> vertex)
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
		GraphJob ccJob = new GraphJob(conf, ConnectedComponent.class);
		ccJob.setJobName("ConnectedComponent");

		ccJob.setVertexClass(CCVertex.class);
		ccJob.setInputPath(new Path(args[0]));
		ccJob.setOutputPath(new Path(args[1]));

		// set the defaults
		 ccJob.setMaxIteration(Integer.MAX_VALUE);

		if (args.length > 2) {
			ccJob.setNumBspTask(Integer.parseInt(args[2]));
		}

		// Vertex reader
		ccJob.setVertexInputReaderClass(CCTextReader.class);

		ccJob.setVertexIDClass(VLongWritable.class);
		ccJob.setVertexValueClass(VLongWritable.class);
		ccJob.setEdgeValueClass(NullWritable.class);

		ccJob.setInputFormat(TextInputFormat.class);

		ccJob.setPartitioner(HashPartitioner.class);
		ccJob.setOutputFormat(TextOutputFormat.class);
		ccJob.setOutputKeyClass(VLongWritable.class);
		ccJob.setOutputValueClass(DoubleWritable.class);
		return ccJob;
	}

	private static void printUsage() {
		System.out.println("Usage: <input> <output> [tasks]");
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

		GraphJob ccJob = createJob(args, conf);

		long startTime = System.currentTimeMillis();
		if (ccJob.waitForCompletion(true)) {
			System.out.println("Job Finished in "
					+ (System.currentTimeMillis() - startTime) / 1000.0
					+ " seconds");
		}
	}
}
