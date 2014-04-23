package comparison.pregelix.hama;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.junit.Test;

public class AllInOneTest {

	final String DIRECTED_ADJLIST_PATH = "src/test/resource/test10.directed.txt";
	final String UNDIRECTED_ADJLIST_PATH = "src/test/resource/test10.undirected.txt";
	final String OUTPUT_FOLDER = "target/testresult";

	private String getOutput(String inputPath, String surfix) {
		return OUTPUT_FOLDER
				+ Path.SEPARATOR
				+ inputPath
						.substring(inputPath.indexOf(Path.SEPARATOR_CHAR) + 1)
				+ surfix;

	}

	@Test
	public void testPageRank() throws ClassNotFoundException, IOException,
			InterruptedException {
		String taskNum = "4";
		String maxIter = "4";
		String inputPath = DIRECTED_ADJLIST_PATH;
		String outputFolder = getOutput(inputPath, ".pagerank");
		PageRank.main(new String[] { inputPath, outputFolder, taskNum, maxIter });

		verifyResult(outputFolder);
	}

	@Test
	public void testSSSP() throws ClassNotFoundException, IOException,
			InterruptedException {
		// <startnode> <input> <output> [tasks]
		String startnode = "0";
		String inputPath = UNDIRECTED_ADJLIST_PATH;
		String outputFolder = getOutput(inputPath, ".sssp");
		String taskNum = "4";
		SSSP.main(new String[] { inputPath, outputFolder, taskNum, startnode });

		verifyResult(outputFolder);
	}

	@Test
	public void testCC() throws ClassNotFoundException, IOException,
			InterruptedException {
		// "Usage: <input> <output> [tasks]"
		String inputPath = UNDIRECTED_ADJLIST_PATH;
		String outputFolder = getOutput(inputPath, ".cc");
		String taskNum = "4";
		ConnectedComponent
				.main(new String[] { inputPath, outputFolder, taskNum });

		verifyResult(outputFolder);
	}

	@Test
	public void testTC() throws ClassNotFoundException, IOException,
			InterruptedException {
		// "Usage: <input> <output> [tasks]");
		String inputPath = UNDIRECTED_ADJLIST_PATH;
		String outputFolder = getOutput(inputPath, ".tc");
		String taskNum = "4";
		TriagleCounting.main(new String[] { inputPath, outputFolder, taskNum });

		verifyResult(outputFolder);
	}

	private static void verifyResult(String outputFolder) throws IOException {
		HashMap<Long, Double> resultVertexInfo = new HashMap<Long, Double>();

		FileSystem fs = FileSystem.get(new Configuration());
		FileStatus[] status = fs.listStatus(new Path(outputFolder));
		for (int i = 0; i < status.length; i++) {
			BufferedReader br = new BufferedReader(new InputStreamReader(
					fs.open(status[i].getPath())));
			String line;
			line = br.readLine();
			while (line != null) {
				resultVertexInfo.put(Long.parseLong(line.split("\\W+")[0]),
						Double.parseDouble(line.split("\\W+")[1]));
				line = br.readLine();
			}
		}

	}
}
