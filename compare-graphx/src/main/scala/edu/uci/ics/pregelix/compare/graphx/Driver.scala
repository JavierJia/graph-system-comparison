package edu.uci.ics.pregelix.compare.graphx

import scala.reflect.ClassTag

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.graphx._
import org.apache.spark.graphx.EdgeTriplet

object Driver {

  def pageRank(sc: SparkContext, inputPath: String, maxIterations: Int): Graph[Double, Double] = {
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1.0, 1.0)
    graph.staticPageRank(maxIterations)
  }

  def connectedComponent(sc: SparkContext, inputPath: String): Graph[VertexId, Int] = {
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1, 1)
    graph.connectedComponents
  }

  def triagleCounting(sc: SparkContext, inputPath: String): Graph[Int, Int] = {
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1, 1).partitionBy(PartitionStrategy.RandomVertexCut)
    graph.triangleCount
  }

  def sssp(sc: SparkContext, inputPath: String, givenSource: Option[Long] = None): Graph[Double, Double] = {
    // Initialize the graph such that all vertices except the root have distance infinity.
    var sourceId = givenSource.getOrElse(sc.textFile(inputPath).first.split("\\W+")(0).toLong)
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1.0, Double.PositiveInfinity);
    val initialGraph = graph.mapVertices((id, _) => if (id == sourceId) 0.0 else Double.PositiveInfinity)
    val sssp = initialGraph.pregel(Double.PositiveInfinity)(
      (id, dist, newDist) => math.min(dist, newDist), // Vertex Program
      triplet => { // Send Message
        if (triplet.srcAttr + triplet.attr < triplet.dstAttr) {
          Iterator((triplet.dstId, triplet.srcAttr + triplet.attr))
        } else {
          Iterator.empty
        }
      },
      (a, b) => math.min(a, b) // Merge Message
      )
    sssp
  }

  def main(args: Array[String]) {
    if (args.length < 4) {
      System.err.println("Usage: Driver <master> <cmd> <inputPath> <outputPath> [cmd-specific-args]")
      System.err.println("\tcmd: [PageRank|CC|SSSP|TC]")
      System.err.println("\tcmd-specific-args: ")
      System.err.println("\t\tPageRank: [maxIterations] default=10")
      System.err.println("\t\tCC: None")
      System.err.println("\t\tTC: None")
      System.err.println("\t\tSSSP: [sourcId] default=first vertex id in the given file")
      System.exit(1)
    }
    var conf = new SparkConf().setMaster(args(0)).setAppName("GraphComparison").set("spark.executor.memory", "8g");

    val sc = new SparkContext(args(0), "GraphXTest",
      System.getenv("SPARK_HOME"), SparkContext.jarOfClass(this.getClass))

    var (cmd, inputPath, outputPath) = (args(1), args(2), args(3))

    cmd.toLowerCase() match {
      case "pagerank" => {
        pageRank(sc, inputPath, if (args.length > 4) args(4).toInt else 10).vertices.saveAsTextFile(outputPath)
      }
      case "cc" => {
        connectedComponent(sc, inputPath).vertices.saveAsTextFile(outputPath)
      }
      case "tc" => {
        triagleCounting(sc, inputPath).vertices.saveAsTextFile(outputPath)
      }
      case "sssp" => {
        sssp(sc, inputPath, if (args.length > 4) Some(args(4).toLong) else None)
      }
    }

    sc.stop()
  }
}