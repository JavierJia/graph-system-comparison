package comparison.pregelix.hama;

import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
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

public class TriagleCounting {

	// using VLong to send each msg, maybe we can save msgs round by
	// ArrayWritable
	public static class TCVertex extends
			Vertex<VLongWritable, VLongWritable, VLongWritable> {

		public Comparator<Edge<VLongWritable, VLongWritable>> edgeComparator = new Comparator<Edge<VLongWritable, VLongWritable>>() {
			@Override
			public int compare(Edge<VLongWritable, VLongWritable> o1,
					Edge<VLongWritable, VLongWritable> o2) {
				return o1.getDestinationVertexID().compareTo(
						o2.getDestinationVertexID());
			}
		};

		@Override
		public void compute(Iterable<VLongWritable> messages)
				throws IOException {
			if (this.getSuperstepCount() == 0) {
				sendNeighborsToEachNeighbor();
			} else {
				triagleCounting(messages);
			}
		}

		private void triagleCounting(Iterable<VLongWritable> messages) {
			long tc = 0;
			for (VLongWritable neighbId : messages) {
				if (Collections.binarySearch(getEdges(),
						new Edge<VLongWritable, VLongWritable>(neighbId,
								new VLongWritable(0)), edgeComparator) >= 0) {
					tc++;
				}
			}
			this.setValue(new VLongWritable(tc));
			voteToHalt();
		}

		private void sendNeighborsToEachNeighbor() throws IOException {
			Collections.sort(getEdges(), edgeComparator);
			for (int i = 0; i < getEdges().size(); ++i) {
				if (getEdges().get(i).getDestinationVertexID().get() < this
						.getVertexID().get()) {
					for (int j = i + 1; j < getEdges().size(); ++j) {
						if (getEdges().get(j).getDestinationVertexID().get() > this
								.getVertexID().get()) {
							sendMessage(getEdges().get(i), getEdges().get(j)
									.getDestinationVertexID());
						}
					}
				} else {
					break;
				}
			}

		}

	}

	public static class TCVertexReader
			extends
			VertexInputReader<LongWritable, Text, VLongWritable, VLongWritable, VLongWritable> {

		@Override
		public boolean parseVertex(LongWritable key, Text value,
				Vertex<VLongWritable, VLongWritable, VLongWritable> vertex)
				throws Exception {
			String line = value.toString();
			String[] nodes = line.split("\\s+");

			vertex.setVertexID(new VLongWritable(Long.parseLong(nodes[0])));
			for (int i = 2; i < nodes.length; ++i) {
				vertex.addEdge(new Edge<VLongWritable, VLongWritable>(
						new VLongWritable(Long.parseLong(nodes[i])), null));
			}
			return true;
		}

	}

	public static GraphJob createJob(String[] args, HamaConfiguration conf)
			throws IOException {
		GraphJob tcJob = new GraphJob(conf, TriagleCounting.class);
		tcJob.setJobName("TriangleCounting");

		tcJob.setVertexClass(TCVertex.class);
		tcJob.setInputPath(new Path(args[0]));
		tcJob.setOutputPath(new Path(args[1]));

		// it should be finished by 2nd round
		tcJob.setMaxIteration(Integer.MAX_VALUE);

		if (args.length > 2) {
			tcJob.setNumBspTask(Integer.parseInt(args[2]));
		}

		// Vertex reader
		tcJob.setVertexInputReaderClass(TCVertexReader.class);

		tcJob.setVertexIDClass(VLongWritable.class);
		tcJob.setVertexValueClass(VLongWritable.class);
		tcJob.setEdgeValueClass(VLongWritable.class);

		tcJob.setInputFormat(TextInputFormat.class);

		tcJob.setPartitioner(HashPartitioner.class);
		tcJob.setOutputFormat(TextOutputFormat.class);
		tcJob.setOutputKeyClass(VLongWritable.class);
		tcJob.setOutputValueClass(VLongWritable.class);
		return tcJob;
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

		GraphJob tcJob = createJob(args, conf);

		long startTime = System.currentTimeMillis();
		if (tcJob.waitForCompletion(true)) {
			System.out.println("Job Finished in "
					+ (System.currentTimeMillis() - startTime) / 1000.0
					+ " seconds");
		}
	}
}
