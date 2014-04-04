package comparison.pregelix.hama;

import java.io.IOException;

import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.VLongWritable;
import org.apache.hama.graph.Edge;
import org.apache.hama.graph.Vertex;

public class ConectedComponent {

	public static class PageRankVertex extends
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
			} else if (this.getSuperstepCount() >= 1) {
				long min = this.getVertexID().get();
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
		}
	}
}
